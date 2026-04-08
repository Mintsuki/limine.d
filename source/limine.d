// SPDX-License-Identifier: 0BSD
//
// Copyright (C) 2026 Mintsuki and contributors.
//
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
// SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
// OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
// CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

module limine;

// Compiler-specific UDA shims for section placement and symbol retention.
// Use @used @section(".name") on __gshared declarations.

version (GNU) {
    import gcc.attributes;
    enum used = attribute("used");
    auto section(string name) { return attribute("section", name); }
} else version (LDC) {
    public import ldc.attributes : section, assumeUsed;
    enum used = assumeUsed;
}

// Misc

private enum ulong[2] commonMagic = [0xc7b1dd30df4c8b88, 0x0a82e883a194f07b];

enum ulong[4] requestsStartMarker = [0xf6b8f4b39de7d1ae, 0xfab91a6940fcb9cf,
                                     0x785c6ed015d3e316, 0x181e920a7852b9d9];
enum ulong[2] requestsEndMarker = [0xadc0e0531bb10d03, 0x9572709f31764c62];

ulong[3] baseRevision(ulong n) {
    return [0xf9562b2d5c95a6c8, 0x6a7b384944536bdc, n];
}

bool baseRevisionSupported(ref const ulong[3] v) {
    return v[2] == 0;
}

bool loadedBaseRevisionValid(ref const ulong[3] v) {
    return v[1] != 0x6a7b384944536bdc;
}

ulong loadedBaseRevision(ref const ulong[3] v) {
    return v[1];
}

struct Uuid {
    uint a;
    ushort b;
    ushort c;
    ubyte[8] d;
}

enum MediaType : uint {
    generic = 0,
    optical = 1,
    tftp = 2,
}

struct File {
    ulong revision;
    void* address;
    ulong size;
    char* path;
    char* string_;
    MediaType mediaType;
    uint unused;
    uint tftpIp;
    uint tftpPort;
    uint partitionIndex;
    uint mbrDiskId;
    Uuid gptDiskUuid;
    Uuid gptPartUuid;
    Uuid partUuid;
}

// Boot info

struct BootloaderInfoResponse {
    ulong revision;
    char* name;
    char* version_;
}

struct BootloaderInfoRequest {
    enum id = [commonMagic[0], commonMagic[1], 0xf55038d8e2a1202f, 0x279426fcf5f59740];

    ulong[4] id_ = id;
    ulong revision;
    BootloaderInfoResponse* response;
}

// Executable command line

struct ExecutableCmdlineResponse {
    ulong revision;
    char* cmdline;
}

struct ExecutableCmdlineRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x4b161536e598651e, 0xb390ad4a2f1f303a];

    ulong[4] id_ = id;
    ulong revision;
    ExecutableCmdlineResponse* response;
}

// Firmware type

enum FirmwareType : ulong {
    x86Bios = 0,
    efi32 = 1,
    efi64 = 2,
    sbi = 3,
}

struct FirmwareTypeResponse {
    ulong revision;
    FirmwareType firmwareType;
}

struct FirmwareTypeRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x8c2f75d90bef28a8, 0x7045a4688eac00c3];

    ulong[4] id_ = id;
    ulong revision;
    FirmwareTypeResponse* response;
}

// Stack size

struct StackSizeResponse {
    ulong revision;
}

struct StackSizeRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x224ef0460a8e8926, 0xe1cb0fc25f46ea3d];

    ulong[4] id_ = id;
    ulong revision;
    StackSizeResponse* response;
    ulong stackSize;
}

// HHDM

struct HhdmResponse {
    ulong revision;
    ulong offset;
}

struct HhdmRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x48dcf1cb8ad2b852, 0x63984e959a98244b];

    ulong[4] id_ = id;
    ulong revision;
    HhdmResponse* response;
}

// Framebuffer

enum FramebufferMemoryModel : ubyte {
    rgb = 1,
}

struct VideoMode {
    ulong pitch;
    ulong width;
    ulong height;
    ushort bpp;
    ubyte memoryModel;
    ubyte redMaskSize;
    ubyte redMaskShift;
    ubyte greenMaskSize;
    ubyte greenMaskShift;
    ubyte blueMaskSize;
    ubyte blueMaskShift;
}

struct Framebuffer {
    void* address;
    ulong width;
    ulong height;
    ulong pitch;
    ushort bpp;
    ubyte memoryModel;
    ubyte redMaskSize;
    ubyte redMaskShift;
    ubyte greenMaskSize;
    ubyte greenMaskShift;
    ubyte blueMaskSize;
    ubyte blueMaskShift;
    ubyte[7] unused;
    ulong edidSize;
    void* edid;
    // Response revision 1
    ulong modeCount;
    VideoMode** modes;
}

struct FramebufferResponse {
    ulong revision;
    ulong framebufferCount;
    Framebuffer** framebuffers;
}

struct FramebufferRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x9d5827dcd881dd75, 0xa3148604f6fab11b];

    ulong[4] id_ = id;
    ulong revision;
    FramebufferResponse* response;
}

// Flanterm FB init params

enum FlantermFbRotation : ulong {
    rotate0 = 0,
    rotate90 = 1,
    rotate180 = 2,
    rotate270 = 3,
}

struct FlantermFbInitParams {
    uint* canvas;
    ulong canvasSize;
    uint[8] ansiColours;
    uint[8] ansiBrightColours;
    uint defaultBg;
    uint defaultFg;
    uint defaultBgBright;
    uint defaultFgBright;
    void* font;
    ulong fontWidth;
    ulong fontHeight;
    ulong fontSpacing;
    ulong fontScaleX;
    ulong fontScaleY;
    ulong margin;
    FlantermFbRotation rotation;
}

struct FlantermFbInitParamsResponse {
    ulong revision;
    ulong entryCount;
    FlantermFbInitParams** entries;
}

struct FlantermFbInitParamsRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x3259399fe7c5f126, 0xe01c1c8c5db9d1a9];

    ulong[4] id_ = id;
    ulong revision;
    FlantermFbInitParamsResponse* response;
}

// Paging mode

enum PagingMode : ulong {
    x86_64_4lvl = 0,
    x86_64_5lvl = 1,
    aarch64_4lvl = 0,
    aarch64_5lvl = 1,
    riscv_sv39 = 0,
    riscv_sv48 = 1,
    riscv_sv57 = 2,
    loongarch_4lvl = 0,
}

struct PagingModeResponse {
    ulong revision;
    PagingMode mode;
}

struct PagingModeRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x95c1a0edab0944cb, 0xa4e5cb3842f7488a];

    ulong[4] id_ = id;
    ulong revision;
    PagingModeResponse* response;
    PagingMode mode;
    PagingMode maxMode;
    PagingMode minMode;
}

// MP

alias GotoAddress = void function(MpInfo*);

version (X86_64) {
    enum MpResponseFlags : uint {
        x2apic = 1 << 0,
    }

    struct MpInfo {
        uint processorId;
        uint lapicId;
        ulong reserved;
        GotoAddress gotoAddress;
        ulong extraArgument;
    }

    struct MpResponse {
        ulong revision;
        MpResponseFlags flags;
        uint bspLapicId;
        ulong cpuCount;
        MpInfo** cpus;
    }
} else version (AArch64) {
    struct MpInfo {
        uint processorId;
        uint reserved1;
        ulong mpidr;
        ulong reserved;
        GotoAddress gotoAddress;
        ulong extraArgument;
    }

    struct MpResponse {
        ulong revision;
        ulong flags;
        ulong bspMpidr;
        ulong cpuCount;
        MpInfo** cpus;
    }
} else version (RISCV64) {
    struct MpInfo {
        ulong processorId;
        ulong hartid;
        ulong reserved;
        GotoAddress gotoAddress;
        ulong extraArgument;
    }

    struct MpResponse {
        ulong revision;
        ulong flags;
        ulong bspHartid;
        ulong cpuCount;
        MpInfo** cpus;
    }
} else version (LoongArch64) {
    struct MpInfo {
        ulong processorId;
        ulong physId;
        ulong reserved;
        GotoAddress gotoAddress;
        ulong extraArgument;
    }

    struct MpResponse {
        ulong revision;
        ulong flags;
        ulong bspPhysId;
        ulong cpuCount;
        MpInfo** cpus;
    }
}

enum MpRequestFlags : ulong {
    x2apic = 1 << 0,
}

struct MpRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x95a67b819a1b857e, 0xa0b61b723b6a73e0];

    ulong[4] id_ = id;
    ulong revision;
    MpResponse* response;
    MpRequestFlags flags;
}

// Memory map

enum MemmapType : ulong {
    usable                = 0,
    reserved              = 1,
    acpiReclaimable       = 2,
    acpiNvs               = 3,
    badMemory             = 4,
    bootloaderReclaimable = 5,
    executableAndModules  = 6,
    framebuffer           = 7,
    reservedMapped        = 8,
}

struct MemmapEntry {
    ulong base;
    ulong length;
    MemmapType type;
}

struct MemmapResponse {
    ulong revision;
    ulong entryCount;
    MemmapEntry** entries;
}

struct MemmapRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x67cf3d9d378a806f, 0xe304acdfc50c3c62];

    ulong[4] id_ = id;
    ulong revision;
    MemmapResponse* response;
}

// Entry point

alias EntryPoint = void function();

struct EntryPointResponse {
    ulong revision;
}

struct EntryPointRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x13d86c035a1cd3e1, 0x2b0caa89d8f3026a];

    ulong[4] id_ = id;
    ulong revision;
    EntryPointResponse* response;
    EntryPoint entry;
}

// Executable File

struct ExecutableFileResponse {
    ulong revision;
    File* executableFile;
}

struct ExecutableFileRequest {
    enum id = [commonMagic[0], commonMagic[1], 0xad97e90e83f1ed67, 0x31eb5d1c5ff23b69];

    ulong[4] id_ = id;
    ulong revision;
    ExecutableFileResponse* response;
}

// Module

enum InternalModuleFlags : ulong {
    required   = 1 << 0,
    compressed = 1 << 1,
}

struct InternalModule {
    const(char)* path;
    const(char)* string_;
    InternalModuleFlags flags;
}

struct ModuleResponse {
    ulong revision;
    ulong moduleCount;
    File** modules;
}

struct ModuleRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x3e7e279702be32af, 0xca1c4f3bd1280cee];

    ulong[4] id_ = id;
    ulong revision;
    ModuleResponse* response;
    // Request revision 1
    ulong internalModuleCount;
    InternalModule** internalModules;
}

// RSDP

struct RsdpResponse {
    ulong revision;
    void* address;
}

struct RsdpRequest {
    enum id = [commonMagic[0], commonMagic[1], 0xc5e77b6b397e7b43, 0x27637845accdcf3c];

    ulong[4] id_ = id;
    ulong revision;
    RsdpResponse* response;
}

// SMBIOS

struct SmbiosResponse {
    ulong revision;
    void* entry32;
    void* entry64;
}

struct SmbiosRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x9e9046f11e095391, 0xaa4a520fefbde5ee];

    ulong[4] id_ = id;
    ulong revision;
    SmbiosResponse* response;
}

// EFI system table

struct EfiSystemTableResponse {
    ulong revision;
    void* address;
}

struct EfiSystemTableRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x5ceba5163eaaf6d6, 0x0a6981610cf65fcc];

    ulong[4] id_ = id;
    ulong revision;
    EfiSystemTableResponse* response;
}

// EFI memory map

struct EfiMemmapResponse {
    ulong revision;
    void* memmap;
    ulong memmapSize;
    ulong descSize;
    ulong descVersion;
}

struct EfiMemmapRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x7df62a431d6872d5, 0xa4fcdfb3e57306c8];

    ulong[4] id_ = id;
    ulong revision;
    EfiMemmapResponse* response;
}

// Date at boot

struct DateAtBootResponse {
    ulong revision;
    long timestamp;
}

struct DateAtBootRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x502746e184c088aa, 0xfbc5ec83e6327893];

    ulong[4] id_ = id;
    ulong revision;
    DateAtBootResponse* response;
}

// Executable address

struct ExecutableAddressResponse {
    ulong revision;
    ulong physicalBase;
    ulong virtualBase;
}

struct ExecutableAddressRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x71ba76863cc55f63, 0xb2644a48c516a487];

    ulong[4] id_ = id;
    ulong revision;
    ExecutableAddressResponse* response;
}

// Device Tree Blob

struct DtbResponse {
    ulong revision;
    void* dtbPtr;
}

struct DtbRequest {
    enum id = [commonMagic[0], commonMagic[1], 0xb40ddb48fb54bac7, 0x545081493f81ffb7];

    ulong[4] id_ = id;
    ulong revision;
    DtbResponse* response;
}

// RISC-V Boot Hart ID

struct RiscvBspHartidResponse {
    ulong revision;
    ulong bspHartid;
}

struct RiscvBspHartidRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x1369359f025525f9, 0x2ff2a56178391bb6];

    ulong[4] id_ = id;
    ulong revision;
    RiscvBspHartidResponse* response;
}

// Bootloader Performance

struct BootloaderPerformanceResponse {
    ulong revision;
    ulong resetUsec;
    ulong initUsec;
    ulong execUsec;
}

struct BootloaderPerformanceRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x6b50ad9bf36d13ad, 0xdc4c7e88fc759e17];

    ulong[4] id_ = id;
    ulong revision;
    BootloaderPerformanceResponse* response;
}

// Keep IOMMU

struct KeepIommuResponse {
    ulong revision;
}

struct KeepIommuRequest {
    enum id = [commonMagic[0], commonMagic[1], 0x8ebaabe51f490179, 0x2aa86a59ffb4ab0f];

    ulong[4] id_ = id;
    ulong revision;
    KeepIommuResponse* response;
}
