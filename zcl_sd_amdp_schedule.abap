class ZCL_SD_TERM_AMDP_PROCESSOR definition
  public
  final
  create public .

 PUBLIC SECTION.
    INTERFACES: if_amdp_marker_hdb.

    TYPES: BEGIN OF ty_assignment,
             vbeln TYPE vbeln_va,
             posnr TYPE posnr_va,
             etenr TYPE etenr,
             charg TYPE charg_d,
             matnr TYPE matnr,
             lgort TYPE lgort_d,
             mbdat TYPE mbdat,
             assigned_qty TYPE menge_d,
             priority_score TYPE int4,
             fvdt6 TYPE fvdat,
             ordqty_bu TYPE menge_d,
             cumulative_assigned TYPE menge_d,
             bobin_rank TYPE int4,
             assignment_flag TYPE char1,
              " === NEW: Sipariş Seviyesi Metrikleri ===
             total_order_qty      TYPE kwmeng,      " VBAP-KWMENG
             total_scheduled_qty  TYPE menge_d,     " SUM(VBEP-ORDQTY_BU)
             total_assigned_qty   TYPE menge_d,     " Bu kaleme atanan toplam
             order_fulfillment    TYPE  p LENGTH 5 DECIMALS 2,        " % (total_assigned / total_order * 100)

             " === NEW: Termin Seviyesi Metrikleri ===
             schedule_capacity    TYPE menge_d,     " VBEP-ORDQTY_BU (bu termin)
             schedule_remaining   TYPE menge_d,     " Kapasite - Atanan
             schedule_utilization TYPE  p LENGTH 5 DECIMALS 2,        " % (atanan / kapasite * 100)

             " === NEW: Timestamp ===
             assignment_timestamp TYPE string,
           END OF ty_assignment.

    TYPES: tt_assignment TYPE STANDARD TABLE OF ty_assignment.

    TYPES: BEGIN OF ty_order,
             vbeln TYPE vbeln_va,
             posnr TYPE posnr_va,
           END OF ty_order.

    TYPES: tt_order TYPE STANDARD TABLE OF ty_order.


    CLASS-METHODS: process_termination
      IMPORTING
        VALUE(iv_ddtype) TYPE z_de_ddtype
        VALUE(i_Statistics) TYPE abap_bool DEFAULT abap_false
        VALUE(it_orders) TYPE tt_order
      EXPORTING
        VALUE(et_assignments) TYPE tt_assignment.




  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_SD_TERM_AMDP_PROCESSOR IMPLEMENTATION.


METHOD process_termination
  BY DATABASE PROCEDURE FOR HDB
  LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY
  USING ZC_ORDER_STOCK mch1 vbep  zsd_t_order_str zsd_t_order_grp zsd_t_termin vbap.


  DECLARE lv_client NVARCHAR(3);
  DECLARE lc_min_qty_threshold DECIMAL(15,3) := 0.0001;
  lv_client = SESSION_CONTEXT( 'CLIENT' );

  IF RECORD_COUNT(:it_orders) = 0 THEN

     AllStock = SELECT * FROM ZC_ORDER_STOCK;


     lt_scored_bobins =
        SELECT    mska.vbeln,
                  mska.posnr,
                  mska.charg,
                  mska.matnr,
                  mska.lgort,
                  ( mska.kalab + mska.kaspe + mska.kains ) as available_qty,
                  COALESCE(b.fvdt6, b.ersda) as ready_date,
                  b.ersda as entry_date,
                  COALESCE(g.priority, 999) as priority_score,
          ROW_NUMBER() OVER ( PARTITION BY mska.vbeln, mska.posnr ORDER BY COALESCE(g.priority, 999),
                                                                           COALESCE(b.fvdt6, b.ersda),
                                                                           b.ersda,
                                                                           mska.charg ) as bobin_rank,
          SUM(mska.kalab) OVER ( PARTITION BY mska.vbeln, mska.posnr ORDER BY COALESCE(g.priority, 999),
                                                                              COALESCE(b.fvdt6, b.ersda),
                                                                              b.ersda,
                                                                              mska.charg
                                                                     ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  ) as bobin_cumulative
          FROM :AllStock AS mska
          INNER JOIN mch1 AS b ON mska.mandt = b.mandt AND mska.matnr = b.matnr AND mska.charg = b.charg
          LEFT JOIN zsd_t_order_str AS s ON mska.mandt = s.mandt AND mska.werks = s.werks AND mska.lgort = s.lgort
          LEFT JOIN zsd_t_order_grp AS g ON s.mandt = g.mandt AND s.group_id = g.group_id
        WHERE mska.mandt = :lv_client;
     --alt kısımlarda kullanıldığı için doldurulmalı
     it_orders = SELECT DISTINCT vbeln,posnr from :lt_scored_bobins  GROUP BY vbeln,posnr;
  ELSEIF RECORD_COUNT(:it_orders) > 0 THEN

    lt_scored_bobins =
    SELECT    mska.vbeln,
              mska.posnr,
              mska.charg,
              mska.matnr,
              mska.lgort,
              ( mska.kalab + mska.kaspe + mska.kains ) as available_qty,
              COALESCE(b.fvdt6, b.ersda) as ready_date,
              b.ersda as entry_date,
              COALESCE(g.priority, 999) as priority_score,
      ROW_NUMBER() OVER ( PARTITION BY mska.vbeln, mska.posnr ORDER BY COALESCE(g.priority, 999),
                                                                       COALESCE(b.fvdt6, b.ersda),
                                                                       b.ersda,
                                                                       mska.charg ) as bobin_rank,
      SUM(mska.kalab) OVER ( PARTITION BY mska.vbeln, mska.posnr ORDER BY COALESCE(g.priority, 999),
                                                                          COALESCE(b.fvdt6, b.ersda),
                                                                          b.ersda,
                                                                          mska.charg
                                                                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  ) as bobin_cumulative
      FROM ZC_ORDER_STOCK AS mska 
      INNER JOIN :it_orders AS io ON mska.vbeln = io.vbeln AND mska.posnr = io.posnr
      INNER JOIN mch1 AS b ON mska.mandt = b.mandt AND mska.matnr = b.matnr AND mska.charg = b.charg
      LEFT JOIN zsd_t_order_str AS s ON mska.mandt = s.mandt AND mska.werks = s.werks AND mska.lgort = s.lgort
      LEFT JOIN zsd_t_order_grp AS g ON s.mandt = g.mandt AND s.group_id = g.group_id
    WHERE mska.mandt = :lv_client;
  END IF;

  lt_scored_bobins = SELECT * FROM :lt_scored_bobins WHERE vbeln <> 'FIRE';
  lt_scored_bobins = SELECT * FROM :lt_scored_bobins WHERE vbeln <> 'STOK';


  IF :iv_ddtype = '2' THEN
      lt_schedule_lines =
        SELECT
          v.vbeln,
          v.posnr,
          v.etenr,
          v.edatu as delivery_date,
          v.ordqty_bu as schedule_capacity,
          SUM(v.ordqty_bu) OVER ( PARTITION BY v.vbeln, v.posnr ORDER BY v.edatu ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) as schedule_cumulative
        FROM vbep AS v
        INNER JOIN :it_orders AS io ON v.vbeln = io.vbeln AND v.posnr = io.posnr
        WHERE v.mandt = :lv_client
          AND v.ordqty_bu > 0;

  ELSE
      lt_schedule_lines =
        SELECT
          v.vbeln,
          v.posnr,
          v.etenr,
          v.tarih  as delivery_date,
          v.sevkacigi as schedule_capacity,
          SUM(v.sevkacigi) OVER ( PARTITION BY v.vbeln, v.posnr ORDER BY v.tarih ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) as schedule_cumulative
        FROM zsd_t_termin  AS v
        INNER JOIN :it_orders AS io ON v.vbeln = io.vbeln AND v.posnr = io.posnr
        WHERE v.mandt = :lv_client
          AND v.ddtype = :iv_ddtype
          AND v.sevkacigi > 0;
  END IF;



   -- En büyük kümülatif kapasite ve en son tarihi bul
  lt_max_schedule =
    SELECT
      vbeln,
      posnr,
      MAX(schedule_cumulative) as max_cumulative,
      MAX(delivery_date) as max_delivery_date
    FROM :lt_schedule_lines
    GROUP BY vbeln, posnr;


    lt_earliest_suitable =
          SELECT
            b.vbeln,
            b.posnr,
            b.charg,
            b.bobin_cumulative,
            b.available_qty,
            MIN(CASE WHEN (b.bobin_cumulative - b.available_qty) < s.schedule_cumulative
                     THEN s.delivery_date END) AS earliest_suitable_date
          FROM :lt_scored_bobins AS b
          LEFT JOIN :lt_schedule_lines AS s ON b.vbeln = s.vbeln AND b.posnr = s.posnr
          GROUP BY b.vbeln, b.posnr, b.charg, b.bobin_cumulative, b.available_qty;


     -- Sequential assignment: Each bobin assigned to FIRST appropriate schedule line only
     lt_assignments =
        SELECT
          b.vbeln,
          b.posnr,
*          s.etenr,
          COALESCE(s.etenr, '9999') AS etenr,
          b.charg,
          b.matnr,
          b.lgort,
          COALESCE(s.delivery_date, '99991231') AS mbdat,
*          s.delivery_date AS mbdat,
          b.priority_score,
          b.ready_date AS fvdt6,
           COALESCE(s.schedule_capacity, 0) AS ordqty_bu,
*          s.schedule_capacity AS ordqty_bu,
          b.bobin_rank,
          s.schedule_cumulative AS cumulative_assigned,
          -- Each bobin assigned to EARLIEST suitable schedule line only
          CASE
            WHEN s.vbeln IS NULL THEN b.available_qty
            -- Bobin fits in this schedule line AND this is the earliest suitable date
            WHEN (b.bobin_cumulative - b.available_qty) < s.schedule_cumulative
                 AND s.delivery_date = es.earliest_suitable_date  THEN b.available_qty  -- Assign full batch to EARLIEST suitable schedule line
*      -- Senaryo 2: Overflow atama (bobin sığmıyor → en son termine at)
        WHEN (b.bobin_cumulative - b.available_qty) >= m.max_cumulative
             AND s.delivery_date = m.max_delivery_date
        THEN b.available_qty
        ELSE 0.0
        END AS assigned_qty,

         CASE
          WHEN s.vbeln IS NULL THEN 'O'  -- Orphan (no schedule)
          WHEN (b.bobin_cumulative - b.available_qty) >= m.max_cumulative
               AND s.delivery_date = m.max_delivery_date
          THEN 'X'  -- Overflow
          ELSE ''   -- Normal
        END AS assignment_flag
        FROM :lt_scored_bobins AS b
        LEFT JOIN :lt_schedule_lines AS s  ON b.vbeln = s.vbeln AND b.posnr = s.posnr
        LEFT JOIN :lt_max_schedule AS m   ON b.vbeln = m.vbeln AND b.posnr = m.posnr
        LEFT JOIN :lt_earliest_suitable AS es ON b.vbeln = es.vbeln AND b.posnr = es.posnr AND b.charg = es.charg;



        -- Sipariş ve termin seviyesinde toplamlar ve oranlar

       lt_order_totals = SELECT vp.vbeln,
                              vp.posnr,
                              vp.kwmeng AS total_order_qty
                            FROM vbap AS vp
                            INNER JOIN :it_orders AS io
                              ON  vp.vbeln = io.vbeln
                              AND vp.posnr = io.posnr
                            WHERE vp.mandt = :lv_client;

    lt_scheduled_totals = SELECT vbeln, posnr, SUM(schedule_capacity) AS total_scheduled_qty
                          FROM :lt_schedule_lines GROUP BY vbeln, posnr;

     lt_order_assigned_totals = SELECT vbeln,
                                       posnr,
                                       SUM(assigned_qty) AS total_assigned_to_order
                                FROM :lt_assignments
    WHERE assigned_qty > :lc_min_qty_threshold
    GROUP BY vbeln, posnr;


    lt_schedule_assigned_totals = SELECT vbeln,
                                         posnr,
                                         etenr,
                                         SUM(assigned_qty) AS total_assigned_to_schedule
                                  FROM :lt_assignments
                                  WHERE assigned_qty > :lc_min_qty_threshold
                                  GROUP BY vbeln, posnr, etenr;




      et_assignments =
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
                              WHEN COALESCE(ot.total_order_qty, 0) > 0
                              THEN (COALESCE(oat.total_assigned_to_order, 0) * 100.0) / ot.total_order_qty
                              ELSE 0
                            END AS INTEGER
                          ) AS order_fulfillment,

                          COALESCE(a.ordqty_bu, 0) AS schedule_capacity,
                          COALESCE(a.ordqty_bu, 0) - COALESCE(sat.total_assigned_to_schedule, 0) AS schedule_remaining,

                          CAST(
                            CASE
                              WHEN COALESCE(a.ordqty_bu, 0) > 0
                              THEN (COALESCE(sat.total_assigned_to_schedule, 0) * 100.0) / a.ordqty_bu
                              ELSE 0
                            END AS INTEGER
                          ) AS schedule_utilization,
*                          TO_VARCHAR(CURRENT_TIMESTAMP) AS assignment_timestamp
                         TO_VARCHAR(
                              CURRENT_TIMESTAMP,
                              'YYYY-MM-DD"T"HH24:MI:SS.ff3'   -- 23 char: 19 + '.' + 3
                            ) AS assignment_timestamp
                        FROM :lt_assignments as a
                       LEFT JOIN :lt_order_totals AS ot
                          ON  a.vbeln = ot.vbeln
                          AND a.posnr = ot.posnr
                        LEFT JOIN :lt_order_assigned_totals AS oat
                          ON  a.vbeln = oat.vbeln
                          AND a.posnr = oat.posnr
                        LEFT JOIN :lt_scheduled_totals AS st
                          ON  a.vbeln = st.vbeln
                          AND a.posnr = st.posnr
                        LEFT JOIN :lt_schedule_assigned_totals AS sat
                          ON  a.vbeln = sat.vbeln
                          AND a.posnr = sat.posnr
                          AND a.etenr = sat.etenr

                        WHERE a.assigned_qty > :lc_min_qty_threshold
                        ORDER BY
                          a.vbeln,
                          a.posnr,
                          a.bobin_rank,
                          a.mbdat,
                          a.etenr;

ENDMETHOD.


ENDCLASS.
