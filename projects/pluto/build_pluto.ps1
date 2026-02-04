# Build script for Pluto HDL project
# This script builds the required IP libraries and then creates the Vivado project

$ErrorActionPreference = "Stop"

# Set environment variable to ignore version check
$env:ADI_IGNORE_VERSION_CHECK = "1"

# Vivado path
$VIVADO = "D:\AMD_DesignTools\2025.2\Vivado\bin\vivado.bat"

# HDL root directory
$HDL_ROOT = "d:\ITASAT-2\Pluto+\hdl-master"

# Required IP libraries for Pluto (in dependency order)
# Build dependencies first, then the main libraries
$IP_LIBS = @(
    "util_cdc",
    "util_axis_fifo",
    "axi_ad9361",
    "axi_dmac",
    "util_pack/util_cpack2",
    "util_pack/util_upack2"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Pluto HDL Project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Clean old project files
Write-Host "Cleaning old project and IP library files..." -ForegroundColor Yellow
$project_path = "$HDL_ROOT\projects\pluto"
if (Test-Path "$project_path\pluto.xpr") {
    Write-Host "  Removing old Vivado project files" -ForegroundColor Gray
    Remove-Item "$project_path\pluto.xpr" -Force -ErrorAction SilentlyContinue
    Remove-Item "$project_path\pluto.cache" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$project_path\pluto.hw" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$project_path\pluto.ip_user_files" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$project_path\pluto.gen" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$project_path\pluto.srcs" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$project_path\pluto.runs" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$project_path\.Xil" -Recurse -Force -ErrorAction SilentlyContinue
}

# Clean IP library builds to force rebuild with fixes
foreach ($lib in $IP_LIBS) {
    $lib_path = Join-Path $HDL_ROOT "library\$lib"
    if (Test-Path $lib_path) {
        Write-Host "  Cleaning IP library: $lib" -ForegroundColor Gray
        Remove-Item "$lib_path\*.xpr" -Force -ErrorAction SilentlyContinue
        Remove-Item "$lib_path\*.cache" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$lib_path\*.hw" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$lib_path\*.ip_user_files" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$lib_path\.Xil" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$lib_path\component.xml" -Force -ErrorAction SilentlyContinue
    }
}
Write-Host ""

# Build each required IP library
foreach ($lib in $IP_LIBS) {
    Write-Host "Building IP library: $lib" -ForegroundColor Yellow
    $lib_path = Join-Path $HDL_ROOT "library\$lib"
    
    if (Test-Path $lib_path) {
        Push-Location $lib_path
        
        # Find the component.xml or create script
        $build_script = Get-ChildItem -Filter "*_ip.tcl" -ErrorAction SilentlyContinue | Select-Object -First 1
        
        if ($build_script) {
            Write-Host "  Running: $($build_script.Name)" -ForegroundColor Gray
            & $VIVADO -mode batch -source $build_script.Name
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  Warning: Build returned exit code $LASTEXITCODE" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  No build script found, skipping..." -ForegroundColor Gray
        }
        
        Pop-Location
    } else {
        Write-Host "  Warning: Library path not found: $lib_path" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Now build the Pluto project
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creating Pluto Vivado Project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Push-Location "$HDL_ROOT\projects\pluto"
& $VIVADO -mode batch -source system_project.tcl

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! Project created successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now open the project in Vivado:" -ForegroundColor Cyan
    Write-Host "  $HDL_ROOT\projects\pluto\pluto.xpr" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
}

Pop-Location
