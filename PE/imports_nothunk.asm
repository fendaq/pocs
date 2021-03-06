; imports with a bogus DLL descriptor with no thunk

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

EXTRADATA equ 65536

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd EXTRADATA + 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN + EXTRADATA
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN + EXTRADATA
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

SIZEOFHEADERS equ $ - IMAGEBASE
section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    push message
    call [__imp__printf]
    add esp, 1 * 4
    push 0
    call [__imp__ExitProcess]
_c

message db " * imports with a bogus DLL descriptor with no thunk", 0ah, 0
_d

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1     , dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd kernel32.dll_iat - IMAGEBASE
iend                                     
istruc IMAGE_IMPORT_DESCRIPTOR           
    at IMAGE_IMPORT_DESCRIPTOR.Name1     , dd bogus.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd bogus.dll_iat - IMAGEBASE
iend                                     
istruc IMAGE_IMPORT_DESCRIPTOR           
    at IMAGE_IMPORT_DESCRIPTOR.Name1     , dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
bogus.dll_iat:
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
bogus.dll
times EXTRADATA db ' '
db 0
_d

align FILEALIGN, db 0

