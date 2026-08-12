# ProvidersMenu Stub Test Data

This directory contains the generator script for stub test data for the `ProvidersMenu` YAMS message (`ProvidersMenuDisplay.proto`).

**Generator Type:** C++ with official protobuf library — guarantees binary compatibility with your actual message serialization.

## Files

- `generateProvidersMenuStub.cpp` — C++ generator using official protobuf serialization
- Generated output (in `../tests/generated/TestData/ProvidersMenu/`):
  - `providers_menu_stub.bin` - Binary protobuf format (for direct use in code)
  - `providers_menu_stub.txt` - Text format (for human readability and reference)

## Data Structure

The stub data contains:

- **3 subsystems**, one per service type
- **2 menu items per subsystem** (6 items total)
- **Base URN**: `urn:ctct:independentlib:providermenu`

### Subsystems Included:

1. Machine Positioning (eMachinePositioning) - `urn:ctct:independentlib:providermenu-1`
2. Height Relative (eHeightRelative) - `urn:ctct:independentlib:providermenu-2`
3. Site Relative (eSiteRelative) - `urn:ctct:independentlib:providermenu-3`

## Usage

### C++ - Loading from Binary File

```cpp
#include "generated/proto/ProvidersMenuDisplay.pb.h"
#include <fstream>

using namespace com::ctct::proto_requests;

// Load from binary file
ProvidersMenu menu;
std::ifstream input("../tests/generated/TestData/ProvidersMenu/providers_menu_stub.bin", std::ios::binary);
if (!menu.ParseFromIstream(&input)) {
    std::cerr << "Failed to parse ProvidersMenu\n";
    return false;
}

// Iterate and display
for (const auto& subsystem : menu.subsystems()) {
    std::cout << "Provider: " << subsystem.provider_urn()
              << " (" << subsystem.provider_display_name() << ")\n";
    for (const auto& item : subsystem.menu_items()) {
        std::cout << "  • " << item.display_text()
                  << " → " << item.url() << "\n";
    }
}
```

### Android - Loading Without Network (DarkCity)

```java
import android.content.Context;
import com.ctct.protoclasses.ProvidersMenu;
import java.io.InputStream;

// Load from assets or resources
Context context = getContext();
InputStream input = context.getResources().openRawResource(R.raw.providers_menu_stub);

ProvidersMenu menu = ProvidersMenu.parseFrom(input);

// Use directly without YAMS subscription
for (ProviderSubsystemMenu subsystem : menu.getSubsystemsList()) {
    String displayName = subsystem.getProviderDisplayName();
    EServiceType serviceType = subsystem.getProviderType();

    for (ProviderMenuItem item : subsystem.getMenuItemsList()) {
        String text = item.getDisplayText();
        String url = item.getUrl();

        // Display menu item, load WebView, etc.
        showMenuItem(text, url);
    }
}
```

### Web (TypeScript/Angular) - Loading Without Network

```typescript
import { ProvidersMenu } from 'generated/proto/proto-yams';

async loadStubProvidersMenu(): Promise<ProvidersMenu> {
    // Fetch from assets directory
    const response = await fetch('assets/test-data/providers_menu_stub.bin');
    const arrayBuffer = await response.arrayBuffer();

    // Deserialize binary protobuf
    return ProvidersMenu.decode(new Uint8Array(arrayBuffer));
}

// Use in component
async ngOnInit() {
    const menu = await this.loadStubProvidersMenu();

    this.menu$ = of(menu);

    menu.subsystems.forEach((subsystem) => {
        console.log(`Provider: ${subsystem.provider_display_name}`);
        subsystem.menu_items.forEach((item) => {
            this.displayMenuItem(item.display_text, item.url);
        });
    });
}
```

## Offline vs. Network Consumption

| Approach                        | Use Case                      | Benefits                                                 | Limitations                     |
| ------------------------------- | ----------------------------- | -------------------------------------------------------- | ------------------------------- |
| **Flat File (Binary/Text)**     | Development, testing, CI/CD   | Fast, deterministic, no network needed, offline-friendly | Static data only                |
| **YAMS Subscription (Network)** | Production, real-time updates | Live data from server, dynamic content, real integration | Requires network, complex setup |

**Hybrid Approach:** Many teams check for a local stub file first (development mode) and fall back to YAMS subscription (production mode):

```typescript
// Angular example
private getProvidersMenu$(): Observable<ProvidersMenu> {
    if (environment.development && this.useStubData) {
        return this.loadStubFromFile();
    }
    return this.messaging.subscribeYamsMessageStream$(ProvidersMenu);
}
```

### C++ - Publishing via YAMS Message Framework

```cpp
// Create a test fixture that loads and publishes the message
auto menu = std::make_shared<ProvidersMenu>();
std::ifstream input("../tests/generated/TestData/ProvidersMenu/providers_menu_stub.bin",
                    std::ios::binary);
menu->ParseFromIstream(&input);

// Publish to the message bus for YAMS to deliver
CMessage<>::Publish(menu);
```

### C++ - Creating in Test Code

For unit tests, you can construct the message inline:

```cpp
TEST(ProvidersMenuTest, StubDataContainsExpectedSubsystems) {
    // Load stub data
    ProvidersMenu menu;
    std::ifstream input("../tests/generated/TestData/ProvidersMenu/providers_menu_stub.bin",
                        std::ios::binary);
    ASSERT_TRUE(menu.ParseFromIstream(&input));

    // Verify structure
    ASSERT_EQ(menu.subsystems_size(), 3);
    EXPECT_EQ(menu.subsystems(0).provider_type(), eMachinePositioning);
    EXPECT_EQ(menu.subsystems(0).menu_items_size(), 2);
}
```

## Regenerating the Stub Data

The C++ generator creates stub data using the official protobuf library, guaranteeing binary compatibility with your C++ runtime.

### Quick Start

```bash
cd cpp
$(which ctct_docker_runner) bash -c "cd scripts && g++ -std=c++17 generateProvidersMenuStub.cpp \
  -I../generated/proto \
  -o generateProvidersMenuStub \
  ../generated/proto/ProvidersMenuDisplay.pb.cc \
  -lprotobuf -pthread && ./generateProvidersMenuStub"
```

### Manual Compilation (without docker)

If you have protobuf libraries installed locally:

```bash
cd cpp/scripts
g++ -std=c++17 generateProvidersMenuStub.cpp \
  -I../generated/proto \
  -o generateProvidersMenuStub \
  ../generated/proto/ProvidersMenuDisplay.pb.cc \
  -lprotobuf -pthread

./generateProvidersMenuStub
```

The generator produces:

- `../tests/generated/TestData/ProvidersMenu/providers_menu_stub.bin` — Binary protobuf (648 bytes)
- `../tests/generated/TestData/ProvidersMenu/providers_menu_stub.txt` — Human-readable debug format

## Distribution to Team

**For sharing with your development team:**

1. **For immediate testing** (text format): Share the generated `providers_menu_stub.txt` as reference
2. **For integration**: Share both `providers_menu_stub.bin` and this README
3. **For reproducibility**: Share the `generateProvidersMenuStub.cpp` script so they can regenerate as needed

The C++ generator uses official protobuf serialization, so the stub data is byte-for-byte identical to how your C++ runtime would create the message.

Example distribution package:

```
ProvidersMenu_TestData/
├── README.md (this file)
├── generateProvidersMenuStub.cpp
├── providers_menu_stub.bin
└── providers_menu_stub.txt
```

## Message Schema Reference

```proto
message ProvidersMenu {
  repeated ProviderSubsystemMenu subsystems = 1;
}

message ProviderSubsystemMenu {
  required string provider_urn = 1;
  required EServiceType provider_type = 2;
  required string provider_display_name = 3;
  repeated ProviderMenuItem menu_items = 4;
}

message ProviderMenuItem {
  required string display_text = 1;
  required string url = 2;
}

enum EServiceType {
  eUndefined = 0;
  eMachinePositioning = 1;
  eHeightRelative = 2;
  eSiteRelative = 3;
}
```

For full schema details, see `/api/yams/operator_ui/ProvidersMenuDisplay.proto`.
