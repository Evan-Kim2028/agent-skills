# Pass: forms

### Keyboard action button has a job

`text-input-action` · Noticeable · Effort: S  
Fix in one phrase: `TextInputAction.next` focuses the next field; `done`/`send` submits on the last field — not only unfocus.

**Detect:** multi-field forms where every field uses default action or all use `done` without `onSubmitted` / `FocusNode` chain / `Form` submit.

**Hunt:** grep `TextFormField|TextField` — check `textInputAction` and `onFieldSubmitted`/`onSubmitted`.

**Why:** users expect the keyboard action key to advance or submit.

**Gotchas:** single-field search may use `search` + submit. Multiline notes use `newline`.

---

### Autofocus single-purpose pages

`autofocus-single-field` · Noticeable on primary search/OTP; Subtle otherwise · Effort: S  
Fix in one phrase: if the screen’s only job is one field, autofocus it on open.

**Detect:** routes that are essentially one `TextField` without `autofocus: true` or post-frame `FocusNode.requestFocus`.

**Hunt:** screens named search/otp/rename/create-tag with a single field.

**Why:** making the user tap the only field is wasted motion.

**Gotchas:** don’t autofocus when keyboard would cover critical instructions.

---

### Cap length with formatters, not angry errors

`max-length-formatter` · Noticeable · Effort: S  
Fix in one phrase: hard limits use `LengthLimitingTextInputFormatter` / custom formatters; don’t wait for submit to yell.

**Detect:** validators that only check max length on submit while the field still accepts more characters; or error while typing past limit instead of blocking.

**Hunt:** grep `maxLength` / `LengthLimiting` / amount validators.

**Why:** preventing overflow feels better than punishing it.

**Gotchas:** soft guidelines may show a counter instead of a hard block.

---

### Dismiss keyboard on outside / scroll when appropriate

`keyboard-dismiss-path` · Noticeable · Effort: S  
Fix in one phrase: scrollable forms use `keyboardDismissBehavior: onDrag` (or equivalent); tap-outside unfocus where platform expects it.

**Detect:** long forms with no dismiss-on-scroll; full-screen barriers that never unfocus.

**Hunt:** grep `ListView|SingleChildScrollView` near forms; check `keyboardDismissBehavior`; scaffold unfocus patterns.

**Why:** trapped keyboards cover CTAs and feel like a stuck app.

**Gotchas:** chat composers often keep focus on purpose.
