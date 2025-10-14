-- Sample SAP HANA SQLScript block to simulate ZCL_SD_TERM_AMDP_PROCESSOR=>PROCESS_TERMINATION
-- The script uses common table expressions (CTEs) to emulate the database tables read by the AMDP
-- and reproduces the core selection logic of the method so that you can inspect the resulting
-- assignments without touching productive data.
--
-- How to use:
--   * Execute this block in SAP HANA Database Explorer or any SQL console connected to a
--     sandbox tenant.
--   * Adjust the inline VALUES clauses if you want to try different scenarios (e.g. change
--     schedule capacities, add new bobins, or tweak priorities).
--   * The final SELECT prints the same columns returned by the AMDP.
--
-- All dates use ISO format (YYYYMMDD) to keep them compatible with NVARCHAR columns.
-- The client is fixed to '100' to match the SESSION_CONTEXT call in the original method.

DO
BEGIN
  DECLARE lc_min_qty_threshold DECIMAL(15,3) := 0.0001;
  DECLARE iv_ddtype NVARCHAR(1) := '2';

  WITH
    it_orders AS (
      SELECT * FROM (
        VALUES
          ('5000000001', '000010'),
          ('5000000001', '000020')
      ) AS orders(vbeln, posnr)
    ),

    zc_order_stock AS (
      SELECT * FROM (
        VALUES
          ('100', '5000000001', '000010', 'BATCH01', 'MAT-STEEL', '0001', 'PL01', 3.0, 1.0, 0.0),
          ('100', '5000000001', '000010', 'BATCH02', 'MAT-STEEL', '0001', 'PL01', 2.0, 1.0, 0.0),
          ('100', '5000000001', '000020', 'BATCH03', 'MAT-STEEL', '0001', 'PL02', 1.0, 1.0, 0.0)
      ) AS stock(mandt, vbeln, posnr, charg, matnr, lgort, werks, kalab, kaspe, kains)
    ),

    mch1 AS (
      SELECT * FROM (
        VALUES
          ('100', 'MAT-STEEL', 'BATCH01', '20240103', '20231201'),
          ('100', 'MAT-STEEL', 'BATCH02', '20240106', '20231202'),
          ('100', 'MAT-STEEL', 'BATCH03', '20240104', '20231203')
      ) AS batches(mandt, matnr, charg, fvdt6, ersda)
    ),

    zsd_t_order_str AS (
      SELECT * FROM (
        VALUES
          ('100', 'PL01', '0001', 'GROUP_A'),
          ('100', 'PL02', '0001', 'GROUP_B')
      ) AS structures(mandt, werks, lgort, group_id)
    ),

    zsd_t_order_grp AS (
      SELECT * FROM (
        VALUES
          ('100', 'GROUP_A', 1),
          ('100', 'GROUP_B', 5)
      ) AS groups(mandt, group_id, priority)
    ),

    vbep AS (
      SELECT * FROM (
        VALUES
          ('100', '5000000001', '000010', '0001', '20240105', 4.0),
          ('100', '5000000001', '000010', '0002', '20240110', 3.0),
          ('100', '5000000001', '000020', '0001', '20240108', 2.0),
          ('100', '5000000001', '000020', '0002', '20240115', 1.0)
      ) AS schedules(mandt, vbeln, posnr, etenr, edatu, ordqty_bu)
    ),

    vbap AS (
      SELECT * FROM (
        VALUES
          ('100', '5000000001', '000010', 7.0),
          ('100', '5000000001', '000020', 3.0)
      ) AS items(mandt, vbeln, posnr, kwmeng)
    ),

    zsd_t_termin AS (
      SELECT * FROM (
        VALUES
          ('100', '5000000001', '000010', '0001', '20240105', 4.0, '2'),
          ('100', '5000000001', '000010', '0002', '20240110', 3.0, '2')
      ) AS legacy(mandt, vbeln, posnr, etenr, tarih, sevkacigi, ddtype)
    ),

    lt_scored_bobins AS (
      SELECT
        mska.vbeln,
        mska.posnr,
        mska.charg,
        mska.matnr,
        mska.lgort,
        (mska.kalab + mska.kaspe + mska.kains) AS available_qty,
        COALESCE(b.fvdt6, b.ersda) AS ready_date,
        b.ersda AS entry_date,
        COALESCE(g.priority, 999) AS priority_score,
        ROW_NUMBER() OVER (
          PARTITION BY mska.vbeln, mska.posnr
          ORDER BY COALESCE(g.priority, 999), COALESCE(b.fvdt6, b.ersda), b.ersda, mska.charg
        ) AS bobin_rank,
        SUM(mska.kalab) OVER (
          PARTITION BY mska.vbeln, mska.posnr
          ORDER BY COALESCE(g.priority, 999), COALESCE(b.fvdt6, b.ersda), b.ersda, mska.charg
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS bobin_cumulative
      FROM zc_order_stock AS mska
      INNER JOIN it_orders AS io
        ON mska.vbeln = io.vbeln AND mska.posnr = io.posnr
      INNER JOIN mch1 AS b
        ON mska.mandt = b.mandt AND mska.matnr = b.matnr AND mska.charg = b.charg
      LEFT JOIN zsd_t_order_str AS s
        ON mska.mandt = s.mandt AND mska.werks = s.werks AND mska.lgort = s.lgort
      LEFT JOIN zsd_t_order_grp AS g
        ON s.mandt = g.mandt AND s.group_id = g.group_id
      WHERE mska.mandt = '100'
    ),

    lt_schedule_lines AS (
      SELECT
        v.vbeln,
        v.posnr,
        v.etenr,
        CASE WHEN iv_ddtype = '2' THEN v.edatu ELSE t.tarih END AS delivery_date,
        CASE WHEN iv_ddtype = '2' THEN v.ordqty_bu ELSE t.sevkacigi END AS schedule_capacity,
        SUM(CASE WHEN iv_ddtype = '2' THEN v.ordqty_bu ELSE t.sevkacigi END)
          OVER (PARTITION BY v.vbeln, v.posnr ORDER BY CASE WHEN iv_ddtype = '2' THEN v.edatu ELSE t.tarih END
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS schedule_cumulative
      FROM vbep AS v
      LEFT JOIN zsd_t_termin AS t
        ON t.mandt = v.mandt AND t.vbeln = v.vbeln AND t.posnr = v.posnr AND t.etenr = v.etenr
      INNER JOIN it_orders AS io
        ON v.vbeln = io.vbeln AND v.posnr = io.posnr
      WHERE v.mandt = '100'
    ),

    lt_max_schedule AS (
      SELECT
        vbeln,
        posnr,
        MAX(schedule_cumulative) AS max_cumulative,
        MAX(delivery_date) AS max_delivery_date
      FROM lt_schedule_lines
      GROUP BY vbeln, posnr
    ),

    lt_earliest_suitable AS (
      SELECT
        b.vbeln,
        b.posnr,
        b.charg,
        b.bobin_cumulative,
        b.available_qty,
        MIN(CASE
              WHEN (b.bobin_cumulative - b.available_qty) < s.schedule_cumulative
              THEN s.delivery_date
            END) AS earliest_suitable_date
      FROM lt_scored_bobins AS b
      LEFT JOIN lt_schedule_lines AS s
        ON b.vbeln = s.vbeln AND b.posnr = s.posnr
      GROUP BY b.vbeln, b.posnr, b.charg, b.bobin_cumulative, b.available_qty
    ),

    lt_assignments AS (
      SELECT
        b.vbeln,
        b.posnr,
        COALESCE(s.etenr, '9999') AS etenr,
        b.charg,
        b.matnr,
        b.lgort,
        COALESCE(s.delivery_date, '99991231') AS mbdat,
        b.priority_score,
        b.ready_date AS fvdt6,
        COALESCE(s.schedule_capacity, 0) AS ordqty_bu,
        b.bobin_rank,
        s.schedule_cumulative AS cumulative_assigned,
        CASE
          WHEN s.vbeln IS NULL THEN b.available_qty
          WHEN (b.bobin_cumulative - b.available_qty) < s.schedule_cumulative
               AND s.delivery_date = es.earliest_suitable_date THEN b.available_qty
          WHEN (b.bobin_cumulative - b.available_qty) >= m.max_cumulative
               AND s.delivery_date = m.max_delivery_date THEN b.available_qty
          ELSE 0.0
        END AS assigned_qty,
        CASE
          WHEN s.vbeln IS NULL THEN 'O'
          WHEN (b.bobin_cumulative - b.available_qty) >= m.max_cumulative
               AND s.delivery_date = m.max_delivery_date THEN 'X'
          ELSE ''
        END AS assignment_flag
      FROM lt_scored_bobins AS b
      LEFT JOIN lt_schedule_lines AS s
        ON b.vbeln = s.vbeln AND b.posnr = s.posnr
      LEFT JOIN lt_max_schedule AS m
        ON b.vbeln = m.vbeln AND b.posnr = m.posnr
      LEFT JOIN lt_earliest_suitable AS es
        ON b.vbeln = es.vbeln AND b.posnr = es.posnr AND b.charg = es.charg
    ),

    lt_order_totals AS (
      SELECT vp.vbeln, vp.posnr, vp.kwmeng AS total_order_qty
      FROM vbap AS vp
      INNER JOIN it_orders AS io
        ON vp.vbeln = io.vbeln AND vp.posnr = io.posnr
      WHERE vp.mandt = '100'
    ),

    lt_scheduled_totals AS (
      SELECT vbeln, posnr, SUM(schedule_capacity) AS total_scheduled_qty
      FROM lt_schedule_lines
      GROUP BY vbeln, posnr
    ),

    lt_order_assigned_totals AS (
      SELECT vbeln, posnr, SUM(assigned_qty) AS total_assigned_to_order
      FROM lt_assignments
      WHERE assigned_qty > lc_min_qty_threshold
      GROUP BY vbeln, posnr
    ),

    lt_schedule_assigned_totals AS (
      SELECT vbeln, posnr, etenr, SUM(assigned_qty) AS total_assigned_to_schedule
      FROM lt_assignments
      WHERE assigned_qty > lc_min_qty_threshold
      GROUP BY vbeln, posnr, etenr
    ),

    final_result AS (
      SELECT
        a.vbeln,
        a.posnr,
        a.etenr,
        a.charg,
        a.matnr,
        a.lgort,
        a.mbdat,
        a.assigned_qty,
        a.priority_score,
        a.fvdt6,
        a.ordqty_bu,
        a.cumulative_assigned,
        a.bobin_rank,
        a.assignment_flag,
        COALESCE(ot.total_order_qty, 0) AS total_order_qty,
        COALESCE(st.total_scheduled_qty, 0) AS total_scheduled_qty,
        COALESCE(oat.total_assigned_to_order, 0) AS total_assigned_qty,
        CAST(
          CASE
            WHEN COALESCE(ot.total_order_qty, 0) > 0 THEN
              (COALESCE(oat.total_assigned_to_order, 0) * 100.0) / ot.total_order_qty
            ELSE 0
          END AS INTEGER
        ) AS order_fulfillment,
        COALESCE(a.ordqty_bu, 0) AS schedule_capacity,
        COALESCE(a.ordqty_bu, 0) - COALESCE(sat.total_assigned_to_schedule, 0) AS schedule_remaining,
        CAST(
          CASE
            WHEN COALESCE(a.ordqty_bu, 0) > 0 THEN
              (COALESCE(sat.total_assigned_to_schedule, 0) * 100.0) / a.ordqty_bu
            ELSE 0
          END AS INTEGER
        ) AS schedule_utilization,
        TO_VARCHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.ff3') AS assignment_timestamp
      FROM lt_assignments AS a
      LEFT JOIN lt_order_totals AS ot
        ON a.vbeln = ot.vbeln AND a.posnr = ot.posnr
      LEFT JOIN lt_order_assigned_totals AS oat
        ON a.vbeln = oat.vbeln AND a.posnr = oat.posnr
      LEFT JOIN lt_scheduled_totals AS st
        ON a.vbeln = st.vbeln AND a.posnr = st.posnr
      LEFT JOIN lt_schedule_assigned_totals AS sat
        ON a.vbeln = sat.vbeln AND a.posnr = sat.posnr AND a.etenr = sat.etenr
      WHERE a.assigned_qty > lc_min_qty_threshold
    )

  SELECT *
  FROM final_result
  ORDER BY vbeln, posnr, bobin_rank, mbdat, etenr;
END;
