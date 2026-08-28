# Plan: {{DESIRE_TITLE}}

- **Created:** {{DATE}}
- **Desire:** {{DESIRE_VERBATIM}}
- **Main repo:** {{MAIN_REPO_PATH}}
- **Worktree:** {{WORKTREE_PATH}}
- **Branch:** {{BRANCH_NAME}} (base: {{BASE_BRANCH}})
- **Documentation impact:** {{WHAT_DOCS_NEED_UPDATING_OR_NONE}}
- **Status:** planning

## Steps

### Step 1: {{STEP_TITLE}}
- **Change:** {{WHAT_WILL_CHANGE}}
- **Files (expected):** {{FILES}}
- **Manual test plan:**
  1. {{TEST_STEP_1}}
  2. {{TEST_STEP_2}}
  - **Expected result:** {{EXPECTED_RESULT}}
- **Status:** pending

### Step 2: {{STEP_TITLE}}
- **Change:** {{WHAT_WILL_CHANGE}}
- **Files (expected):** {{FILES}}
- **Manual test plan:**
  1. {{TEST_STEP_1}}
  - **Expected result:** {{EXPECTED_RESULT}}
- **Status:** pending

<!-- Add as many code steps as needed, numbered in order. Each step's manual
     test should verify exactly one thing. -->

### Step N: Update documentation
<!-- Only include this step if Documentation impact above is not "none". It
     always goes last, after every code step is implemented and confirmed —
     document what actually got built. -->
- **Change:** {{WHICH_DOCS_AND_WHAT_CHANGES}}
- **Files (expected):** {{DOC_FILES}}
- **Manual test plan:**
  1. {{TEST_STEP_1}}
  - **Expected result:** {{EXPECTED_RESULT}}
- **Status:** pending

## Log

<!-- Append one entry per step, only after sign-off and commit. Don't edit past
     entries.

### Step 1 — {{STEP_TITLE}} — {{TIMESTAMP}}
- Commit: `{{SHORT_SHA}}`
- Summary: {{WHAT_ACTUALLY_CHANGED}}
- Manual test: {{RESTATE_TEST_STEPS}}
- Result: confirmed working by user
-->
