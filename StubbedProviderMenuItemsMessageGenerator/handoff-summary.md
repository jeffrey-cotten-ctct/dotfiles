# ProvidersMenu Stub Generator Handoff

## Purpose
Create and share stubbed `ProvidersMenu` protobuf messages for teams that need to develop/test without a live YAMS server.

## Current Source of Truth
- Generator: `generateProvidersMenuStub.py`
- Latest generated binary: `stub_data/providers_menu_stub.bin`
- Latest generated text: `stub_data/providers_menu_stub.txt`
- Raw chat archive: `chat_history/d88bf0f7-b497-4c88-b5d1-6155948de74b.jsonl`

## Final Message Shape (Current)
- 2 subsystems
  - `provider_urn: "urn:providernamespace:machine-controls"`
  - `provider_type: eMachinePositioning`
  - 6 menu items
  - `provider_urn: "urn:providernamespace:positioning"`
  - `provider_type: eSiteRelative`
  - 2 menu items
- Text output shows enum names (`eMachinePositioning`, `eSiteRelative`) for readability.
- Binary output encodes enums as numeric values per protobuf wire format.

## Important Notes
- The generator uses manual protobuf wire-format encoding (no external dependency).
- `ProvidersMenu_README.md` still contains older C++-generator references and should be treated as partially outdated.
- The generated text format is for readability only; integration should use the `.bin` file.

## How To Regenerate
From this folder:

```bash
cd ~/source/dotfiles/StubbedProviderMenuItemsMessageGenerator
python3 generateProvidersMenuStub.py
```

## Expected Outputs
The script currently writes to:

- `../tests/generated/TestData/ProvidersMenu/providers_menu_stub.bin`
- `../tests/generated/TestData/ProvidersMenu/providers_menu_stub.txt`

For this repo, the canonical copy to share is kept in `stub_data/`.

## Recommended Next Cleanup
1. Update `generateProvidersMenuStub.py` output path to local `stub_data/`.
2. Refresh `ProvidersMenu_README.md` to remove C++ generator instructions and match current Python workflow.
3. Keep this handoff file and `chat_history/` for future AI sessions.
