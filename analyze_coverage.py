#!/usr/bin/env python3
import re
import sys

def analyze_coverage(lcov_file, feature_path):
    with open(lcov_file, 'r') as f:
        content = f.read()
    
    # Split by SF (source file) markers
    files = re.split(r'^SF:', content, flags=re.MULTILINE)
    
    total_lines = 0
    executed_lines = 0
    files_analyzed = 0
    
    for file_section in files:
        if feature_path in file_section:
            files_analyzed += 1
            # Count DA lines (line execution data)
            da_matches = re.findall(r'^DA:(\d+),(\d+)$', file_section, re.MULTILINE)
            for line_num, exec_count in da_matches:
                total_lines += 1
                if int(exec_count) > 0:
                    executed_lines += 1
    
    if total_lines > 0:
        coverage = (executed_lines / total_lines) * 100
        print(f'FoodSearch Feature Coverage Analysis:')
        print(f'  Files Analyzed: {files_analyzed}')
        print(f'  Total Lines: {total_lines}')
        print(f'  Executed Lines: {executed_lines}')
        print(f'  Unexecuted Lines: {total_lines - executed_lines}')
        print(f'  Coverage: {coverage:.2f}%')
        print(f'  Target: 70%')
        status = 'PASS' if coverage >= 70 else 'FAIL'
        print(f'  Status: {status}')
        return coverage >= 70
    else:
        print('No FoodSearch files found in coverage report')
        return False

if __name__ == '__main__':
    success = analyze_coverage('coverage/lcov.info', 'lib\\features\\FoodSearch')
    sys.exit(0 if success else 1)
