# Maestro: Camera Capture, Upload, And Cleanup

Date: 2026-06-06
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A

## Objective

Align Android camera ownership with `image_picker` and add one Maestro journey
proving the profile-photo action launches the system camera and returns cleanly
after a captured frame is accepted, uploaded, rendered, and removed.

## Dependencies

- `2026-06-06_maestro-login-logout-resettable-identity.md` for authenticated
  access to profile photo editing.

## Platform Contract

- Android: `image_picker` uses the system camera intent; no app CAMERA
  permission is required.
- iOS: `NSCameraUsageDescription` remains required and native camera denial can
  still be reported to the app.
- Upload one generated emulator image and remove it before completion.
- The fixture trap must clear the profile image after interrupted or failed
  runs.

## Acceptance Criteria

1. The Android manifest does not request CAMERA permission.
2. The user chooses the profile-photo camera action.
3. The system camera activity opens and captures one frame.
4. The review screen appears and Done accepts the captured frame.
5. The app completes the backend upload and renders the updated state.
6. The flow removes the photo and verifies removal.
7. Fixture cleanup independently verifies no profile image remains.

## Implementation Checklist

- [x] Verify the upstream Android and iOS setup contracts.
- [x] Remove the unnecessary Android CAMERA permission.
- [x] Retain iOS usage description and permission-error mapping.
- [x] Add `.maestro/flows/account/camera_capture_upload_cleanup.yaml`.
- [x] Add fixture-backed `./mobtrace verify camera-launch`.
- [x] Prove the flow on Medium Phone and record the artifact path.
- [x] Prove capture, review, rejection, and cancellation on Medium Phone.
- [ ] Prove upload, rendered state, UI removal, and trap cleanup.

## Evidence

- Device: Medium Phone, Android API 35, `emulator-5554`
- APK manifest: CAMERA permission absent
- Result: passed in 35 seconds
- Artifacts: `_artifacts/mobile/dogfood-camera-launch-20260609-run2`
- Capture/reject result: passed in 39 seconds
- Capture/reject artifacts:
  `_artifacts/mobile/dogfood-camera-capture-reject-20260609-run1`
- Upload/cleanup result: passed in 45 seconds
- Upload/cleanup artifacts:
  `_artifacts/mobile/dogfood-camera-upload-cleanup-20260609-run2`

## Verification

```bash
./mobtrace verify camera-launch \
  --device emulator-5554 \
  --flavor dev
```

## Risks And Mitigations

- Risk: the system camera UI and review controls are emulator/image dependent.
- Mitigation: pin the Medium Phone baseline and assert Camera2 resource IDs.

## Handoff Notes

The earlier denial/recovery proposal was invalid for Android because the app
does not own camera capture. The final journey covers the real user outcome,
including backend upload and deterministic cleanup.
