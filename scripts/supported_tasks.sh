#!/bin/bash
set -euo pipefail

export all_tasks=(
    "readmission/general_hospital/30d"
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    "abnormal_lab/blood_chemistry/hypoglycemia/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "mortality/in_icu/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/blood_chemistry/metabolic_acidosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)
export AUMCdb=(
    "readmission/general_hospital/30d"
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "mortality/in_icu/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)

export EHRShot=(
    "readmission/general_hospital/30d"
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    # "abnormal_lab/blood_chemistry/hypoglycemia/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "mortality/in_icu/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)

export HIRID=(
    # "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    "abnormal_lab/blood_chemistry/hypoglycemia/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "mortality/in_icu/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/blood_chemistry/metabolic_acidosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)

export INSPIRE=(
    "readmission/general_hospital/30d"
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "mortality/in_icu/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)

export MIMIC_IV=(
    "readmission/general_hospital/30d"
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    "abnormal_lab/blood_chemistry/hypoglycemia/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "mortality/in_icu/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/blood_chemistry/metabolic_acidosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)

export NWICU=(
    "readmission/general_hospital/30d"
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    "abnormal_lab/blood_chemistry/hypoglycemia/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "mortality/in_icu/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)

export SICdb=(
    "readmission/general_hospital/30d"
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "mortality/in_icu/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)

export eICU=(
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    "abnormal_lab/blood_chemistry/hypoglycemia/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "mortality/in_icu/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)

export MSHS=(
    "readmission/general_hospital/30d"
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    "abnormal_lab/blood_chemistry/hypoglycemia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
)

# Define supported tasks for each dataset
declare -A DATASETS
DATASETS["AUMCdb"]="${AUMCdb[*]}"
DATASETS["EHRShot"]="${EHRShot[*]}"
DATASETS["HIRID"]="${HIRID[*]}"
DATASETS["INSPIRE"]="${INSPIRE[*]}"
DATASETS["MIMIC-IV"]="${MIMIC_IV[*]}"
DATASETS["NWICU"]="${NWICU[*]}"
DATASETS["SICdb"]="${SICdb[*]}"
DATASETS["eICU"]="${eICU[*]}"
DATASETS["MSHS"]="${MSHS[*]}"
export DATASETS
