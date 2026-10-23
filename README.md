# KillWindowsCrap

A lightweight batch utility designed to instantly silence disk-choking background services, permanently freeze forced Windows Updates, and neutralize common VBScript startup trojans on low-spec PCs running older mechanical HDDs.

---

## The Problem

On machines with 5400 RPM hard drives and limited RAM (e.g., older laptops running 32-bit/64-bit Windows 10), Microsoft's background services frequently trigger continuous 100% disk active time. 

Even when total throughput is only 5–8 MB/s, the unbuffered 4KB random reads/writes from update orchestrators, telemetry agents, and component indexers completely bottleneck the system queue depth, rendering the PC unusable.

---

## What This Script Does

1. **Kills Thrashing Processes**: Instantly terminates active instances of `TiWorker.exe`, `TrustedInstaller.exe`, and stray `wscript.exe` processes.
2. **Neutralizes Windows Update**:
   - Stops and sets `wuauserv`, `bits`, and `dosvc` to `Disabled`.
   - Rebinds `wuauserv` to `NT AUTHORITY\NetworkService` to strip execution privileges and prevent rogue self-restarts.
   - Disables `WaaSMedicSvc` (Windows Update Medic Service) directly in the registry so Windows cannot auto-repair or resurrect the updater.
3. **Optimizes HDD I/O**:
   - Disables `SysMain` (Superfetch) to stop constant preloading thrash.
   - Disables `WSearch` (Windows Search Indexer) and `DiagTrack` (Connected User Experiences and Telemetry).
4. **Locks Group Policy**: Applies registry overrides under `Policies\Microsoft\Windows\WindowsUpdate\AU` (`NoAutoUpdate=1`, `AUOptions=2`).
5. **Kills Servicing Tasks**: Disables scheduled auto-wake tasks (`Scheduled Start`, `PerformRemediation`, `StartComponentCleanup`).
6. **Cleans Pending Updates**: Wipes `SoftwareDistribution\Download` and clears the `RebootRequired` registry flag to prevent endless "Preparing Windows" rollback loops on shutdown.
7. **Silences VBScript Worm Errors**: Deletes startup registry persistence keys (such as `Video.3gp`) and seeds an empty 0-byte dummy file so Windows Script Host exits silently without error pop-ups.

---

## Usage

1. Download [`KillWindowsCrap.bat`](KillWindowsCrap.bat).
2. Right-click the file and select **Run as administrator** (or run it from an elevated Command Prompt: `C:\Windows\system32>`).
3. Wait for the terminal to print `[DONE]`.
4. Restart the computer to clear remaining staged memory handles.

---

## Verification

To verify that the update service is completely locked out, run this command in an elevated prompt:

```cmd
sc query wuauserv && sc qc wuauserv
