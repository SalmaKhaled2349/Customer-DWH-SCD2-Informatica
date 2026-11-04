# Informatica asset reference (from exported mappings)

These notes describe selected settings visible in the Informatica export. They are **not executable or importable mapping definitions**.

## `customers_source_to_landing`

- Source: customer CSV snapshot
- Expression: `Hash_Key` calculated as `MD5(Customer_ID || Customer_Name || City || Country || Customer_Status)`
- Target: `landing_layer.Customer`
- Mapping Task: truncate target before loading, so LANDING reflects the latest supplied snapshot

## `customers_landing_to_staging`

Two branches in one mapping:

- New / changed / reactive: current non-deleted STAGING versus LANDING on `Hash_Key`; filter null `stg_Stage_SK`; Lookup on `Customer_ID` against current versions including deleted versions; classify and route to INSERT and/or close-and-INSERT targets.
- Deleted: current active STAGING versus LANDING on `Customer_ID`; retain rows absent from LANDING; close old version and insert deleted version.

Source filters serve different purposes: the hash comparison considers `Is_Current=1 AND Is_Deleted=0`; the customer Lookup uses `Is_Current=1` so it can find a deleted version for reactivation.

## `customers_staging_to_customersdim`

Exported transformation chain:

`customers_staging_layer → Lookup → Expression → Router → Insert_dim_customers / Update_dim_customers`

- Source is `staging_layer.Customers` with no current/nondeleted-only filter in the exported mapping.
- Lookup object: `Dim_Customers`
- Lookup condition: lookup `Stage_SK = stg_Stage_SK`
- Lookup source filter: **empty**
- Returned/renamed for the Expression: `lkup_Customer_SK`, `lkup_Is_Current`, `lkup_End_Date`
- Expression output name: `Record_Action`
- Exact exported expression (formatting simplified):

```text
IIF(ISNULL(lkup_Customer_SK), 'Insert',
    IIF(lkup_Is_Current <> stg_Is_Current OR
        lkup_End_Date <> stg_End_Date,
        'Update', 'Skip'))
```

- Router `Insert`: `Record_Action = 'Insert'`
- Router `Update`: `Record_Action = 'Update'`
- `DEFAULT1` unconnected; `Skip` requires no write
- Insert target maps staging fields (including `Stage_SK` and historical flags), omitting the dimension-generated `Customer_SK`.
- Update target maps `Customer_SK ← lkup_Customer_SK`, `End_Date ← stg_End_Date`, `Is_Current ← stg_Is_Current`.

**Important:** The exported expression's `End_Date <>` comparison is not NULL-safe. This is an implementation limitation to test and improve; this document does not assert the issue has already been fixed.
