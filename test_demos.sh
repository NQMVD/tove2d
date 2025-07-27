#!/bin/bash

# Automated demo testing script for TÖVE
# Tests each demo for 3 seconds and captures output

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run a demo with timeout and capture output
run_demo() {
  local demo_name="$1"
  local demo_path="demos/$demo_name"

  echo -e "${BLUE}Testing demo: $demo_name${NC}"
  echo "----------------------------------------"

  if [ ! -d "$demo_path" ]; then
    echo -e "${RED}❌ Demo directory not found: $demo_path${NC}"
    return 1
  fi

  # Create output file
  local output_file="logs/test_output_${demo_name}.log"
  mkdir -p logs
  touch "$output_file"

  # Run love with timeout, capturing both stdout and stderr
  love "$demo_path" >"$output_file" 2>&1 &
  local pid=$!

  # Wait for 3 seconds then kill the process
  sleep 5
  kill $pid 2>/dev/null || true
  wait $pid 2>/dev/null || true
  local exit_code=$?

  # Check if the demo had errors
  if [ -s "$output_file" ]; then
    echo -e "${YELLOW}📋 Output captured:${NC}"
    cat "$output_file"

    # Check for common error patterns
    if grep -i "error\|exception\|failed\|nil\|stack traceback" "$output_file" >/dev/null; then
      echo -e "${RED}❌ ERRORS DETECTED${NC}"
      return 1
    else
      echo -e "${GREEN}✅ No obvious errors detected${NC}"
      return 0
    fi
  else
    echo -e "${GREEN}✅ No output (likely started successfully)${NC}"
    return 0
  fi
}

# Show usage if help requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0 [demo1] [demo2] ..."
  echo ""
  echo "Test TÖVE demos for Love2D 12.0 compatibility"
  echo ""
  echo "Arguments:"
  echo "  demo1, demo2...  Specific demo directory names to test"
  echo "                   (if none provided, tests all demos with main.lua)"
  echo ""
  echo "Examples:"
  echo "  $0                    # Test all demos"
  echo "  $0 shaders fillrule   # Test only shaders and fillrule demos"
  echo "  $0 zoom hearts blob   # Test specific demos for debugging"
  exit 0
fi

# Main execution
echo -e "${BLUE}TÖVE Demo Compatibility Test${NC}"
echo -e "${BLUE}Testing with Love2D version:${NC}"
love --version
echo ""

# Get list of demo directories that contain main.lua
demo_dirs=()

if [ $# -gt 0 ]; then
  # Use command line arguments as demo list
  for demo in "$@"; do
    if [ -f "demos/$demo/main.lua" ]; then
      demo_dirs+=("$demo")
      echo -e "${BLUE}Will test specified demo: $demo${NC}"
    else
      echo -e "${RED}⚠️  Skipping '$demo' - no main.lua found in demos/$demo/${NC}"
    fi
  done
  echo ""
else
  # Auto-discover all demos with main.lua
  echo -e "${BLUE}No specific demos specified, auto-discovering all demos...${NC}"
  for dir in demos/*/; do
    if [ -f "$dir/main.lua" ]; then
      demo_dirs+=($(basename "$dir"))
    fi
  done
  echo -e "${BLUE}Found ${#demo_dirs[@]} demos to test${NC}"
  echo ""
fi

if [ ${#demo_dirs[@]} -eq 0 ]; then
  echo -e "${RED}No valid demos found to test!${NC}"
  exit 1
fi

# Results tracking
declare -a working_demos
declare -a broken_demos
declare -a issue_demos

# Test each demo
for demo in "${demo_dirs[@]}"; do
  if run_demo "$demo"; then
    if [ -f "logs/test_output_${demo}.log" ] && [ -s "logs/test_output_${demo}.log" ]; then
      issue_demos+=("$demo")
    else
      working_demos+=("$demo")
    fi
  else
    broken_demos+=("$demo")
  fi
  echo ""
done

# Summary report
echo -e "${BLUE}========================================${NC}"
if [ $# -gt 0 ]; then
  echo -e "${BLUE}TESTING SUMMARY (${#demo_dirs[@]} specified demos)${NC}"
else
  echo -e "${BLUE}TESTING SUMMARY (all ${#demo_dirs[@]} demos)${NC}"
fi
echo -e "${BLUE}========================================${NC}"

echo -e "${GREEN}✅ Working demos (${#working_demos[@]}):${NC}"
for demo in "${working_demos[@]}"; do
  echo "  - $demo"
done

echo ""
echo -e "${YELLOW}⚠️  Demos with issues (${#issue_demos[@]}):${NC}"
for demo in "${issue_demos[@]}"; do
  echo "  - $demo"
done

echo ""
echo -e "${RED}❌ Broken demos (${#broken_demos[@]}):${NC}"
for demo in "${broken_demos[@]}"; do
  echo "  - $demo"
done

echo ""
echo -e "${BLUE}📁 Log files created:${NC}"
ls -la logs/test_output_*.log 2>/dev/null || echo "No log files created"

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review log files for specific errors"
echo "2. Update TODO.md with findings"
echo "3. Prioritize fixes based on demo importance"

# Cleanup option
echo ""
read -p "Remove log files? (y/N): " cleanup
if [[ $cleanup =~ ^[Yy]$ ]]; then
  rm -f logs/test_output_*.log
  echo "Log files removed"
fi
