# AMDP Simulation Samples

This directory contains handcrafted datasets that mimic the database state expected by
`ZCL_SD_TERM_AMDP_PROCESSOR=>PROCESS_TERMINATION`. The goal is to make it easy to explore and
debug the AMDP logic without requiring access to production data.

## Files

- `zcl_sd_term_amdp_processor_simulation.sql` – self-contained SQLScript block that
  recreates the logic of the AMDP on top of inline sample data. You can run it inside
  SAP HANA Database Explorer to see how bobin assignments, schedule utilization, and
  fulfillment percentages are calculated.

## Usage

1. Open a SQL console on a non-productive SAP HANA system.
2. Copy the contents of `zcl_sd_term_amdp_processor_simulation.sql` into the console and execute it.
3. Review the final result set to understand how the AMDP distributes bobins across schedule lines.
4. Adjust the inline `VALUES` blocks to try different scenarios (new priorities, additional
   schedule lines, orphaned bobins, overflow cases, etc.).

The script sticks to the same column names and calculations as the original AMDP, so the
output columns mirror the method's export table.
