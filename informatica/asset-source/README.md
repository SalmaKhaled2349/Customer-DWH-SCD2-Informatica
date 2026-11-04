# Sanitized Informatica Asset Definitions

These seven files were extracted from the original Informatica Cloud CDI export for the Customer DWH SCD2 project.

- `mappings/`: **3 full mapping transformation graphs**, including transformation settings and links (JSON).
- `mapping-tasks/`: **3 mapping task configuration records** (JSON).
- `taskflow/`: **1 taskflow definition** (XML).

## Why the files look different from the original Export ZIP

The original vendor export embeds technical definitions in nested ZIPs, plus references to a specific account, runtime environment, and connections. This public documentation copy keeps the transformation and taskflow definitions but redacts account emails, connection/runtime references, and machine-specific paths.

**Important:** These are *sanitized source definitions for code review*, not a tested or directly importable Informatica migration package. To migrate/re-run in another Informatica environment, use a securely held official export and rebind connections and runtime environments during the vendor's import process. Do not publish the original export without assessing its account/environment references.

This package documents the structure as it existed at export time; it does not prove that all SCD Type 2 change scenarios passed testing.
