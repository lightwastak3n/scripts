#!/usr/bin/env python3
"""
Analyze Python codebase statistics using ast module.
Counts lines of code, functions, classes, comments, and more.
"""

import argparse
import ast
import os
from pathlib import Path
from collections import Counter
from typing import Dict, List, Set


# Default directories to ignore
DEFAULT_IGNORE_DIRS = {
    '.venv', 'venv', 'virtualenv', '__pycache__',
    'alembic', 'migrations', '.git', '.pytest_cache',
    '.idea', '.vscode', 'node_modules', 'build', 'dist',
    '.eggs', '.tox', '.coverage', 'htmlcov',
}

# Global set for dynamic ignore patterns (updated by CLI args)
IGNORE_DIRS: Set[str] = set(DEFAULT_IGNORE_DIRS)
IGNORE_FILES: Set[str] = set()


def should_ignore(path: Path) -> bool:
    """Check if a path should be ignored."""
    # Check if any parent directory is in ignore list
    for part in path.parts:
        if part in IGNORE_DIRS or part.startswith('.'):
            return True
        if part.endswith('.egg-info') or part == '__pycache__':
            return True

    # Check if file itself is in ignore list
    if path.name in IGNORE_FILES:
        return True

    return False


def is_python_file(path: Path) -> bool:
    """Check if a file is a Python file."""
    return path.suffix == '.py' and not path.name.startswith('__')


class CodeAnalyzer(ast.NodeVisitor):
    """AST visitor to collect code statistics."""

    def __init__(self, source_lines: List[str]):
        self.source_lines = source_lines
        self.stats = {
            'classes': 0,
            'functions': 0,
            'async_functions': 0,
            'methods': 0,
            'class_methods': 0,
            'static_methods': 0,
            'properties': 0,
            'imports': 0,
            'from_imports': 0,
            'decorators': 0,
            'args': 0,
            'kwargs': 0,
            'lambda_functions': 0,
            'comprehensions': 0,
            'try_except_blocks': 0,
            'if_statements': 0,
            'for_loops': 0,
            'while_loops': 0,
            'with_statements': 0,
            'assignments': 0,
            'annotated_assignments': 0,
            'calls': 0,
            'strings': 0,
            'numbers': 0,
            'lists': 0,
            'dicts': 0,
            'sets': 0,
            'tuples': 0,
        }
        self.class_stack = []  # Track if we're inside a class

    def visit_ClassDef(self, node: ast.ClassDef):
        self.stats['classes'] += 1
        self.stats['decorators'] += len(node.decorator_list)
        self.class_stack.append(node.name)
        self.generic_visit(node)
        self.class_stack.pop()

    def visit_FunctionDef(self, node: ast.FunctionDef):
        if self.class_stack:
            self.stats['methods'] += 1
            # Check for classmethod, staticmethod, property
            for decorator in node.decorator_list:
                if isinstance(decorator, ast.Name):
                    if decorator.id == 'classmethod':
                        self.stats['class_methods'] += 1
                    elif decorator.id == 'staticmethod':
                        self.stats['static_methods'] += 1
                    elif decorator.id == 'property':
                        self.stats['properties'] += 1
                elif isinstance(decorator, ast.Attribute):
                    if decorator.attr == 'setter':
                        self.stats['properties'] += 1
        else:
            self.stats['functions'] += 1
        self.stats['decorators'] += len(node.decorator_list)

        # Count arguments
        args = node.args
        self.stats['args'] += len(args.args)
        self.stats['kwargs'] += len(args.kwonlyargs)
        if args.vararg:
            self.stats['kwargs'] += 1
        if args.kwarg:
            self.stats['kwargs'] += 1

        self.generic_visit(node)

    def visit_AsyncFunctionDef(self, node: ast.AsyncFunctionDef):
        self.stats['async_functions'] += 1
        self.stats['decorators'] += len(node.decorator_list)
        # Count like regular functions
        if self.class_stack:
            self.stats['methods'] += 1
        else:
            self.stats['functions'] += 1

        args = node.args
        self.stats['args'] += len(args.args)
        self.stats['kwargs'] += len(args.kwonlyargs)
        if args.vararg:
            self.stats['kwargs'] += 1
        if args.kwarg:
            self.stats['kwargs'] += 1

        self.generic_visit(node)

    def visit_Import(self, node: ast.Import):
        self.stats['imports'] += len(node.names)
        self.generic_visit(node)

    def visit_ImportFrom(self, node: ast.ImportFrom):
        self.stats['from_imports'] += len(node.names)
        self.generic_visit(node)

    def visit_Lambda(self, node: ast.Lambda):
        self.stats['lambda_functions'] += 1
        self.generic_visit(node)

    def visit_ListComp(self, node: ast.ListComp):
        self.stats['comprehensions'] += 1
        self.generic_visit(node)

    def visit_SetComp(self, node: ast.SetComp):
        self.stats['comprehensions'] += 1
        self.generic_visit(node)

    def visit_DictComp(self, node: ast.DictComp):
        self.stats['comprehensions'] += 1
        self.generic_visit(node)

    def visit_GeneratorExp(self, node: ast.GeneratorExp):
        self.stats['comprehensions'] += 1
        self.generic_visit(node)

    def visit_Try(self, node: ast.Try):
        self.stats['try_except_blocks'] += 1
        self.generic_visit(node)

    def visit_If(self, node: ast.If):
        self.stats['if_statements'] += 1
        self.generic_visit(node)

    def visit_For(self, node: ast.For):
        self.stats['for_loops'] += 1
        self.generic_visit(node)

    def visit_While(self, node: ast.While):
        self.stats['while_loops'] += 1
        self.generic_visit(node)

    def visit_With(self, node: ast.With):
        self.stats['with_statements'] += 1
        self.generic_visit(node)

    def visit_Assign(self, node: ast.Assign):
        self.stats['assignments'] += 1
        self.generic_visit(node)

    def visit_AnnAssign(self, node: ast.AnnAssign):
        self.stats['annotated_assignments'] += 1
        self.generic_visit(node)

    def visit_Call(self, node: ast.Call):
        self.stats['calls'] += 1
        self.generic_visit(node)

    def visit_Constant(self, node: ast.Constant):
        if isinstance(node.value, str):
            self.stats['strings'] += 1
        elif isinstance(node.value, (int, float, complex)):
            self.stats['numbers'] += 1
        self.generic_visit(node)

    def visit_List(self, node: ast.List):
        self.stats['lists'] += 1
        self.generic_visit(node)

    def visit_Dict(self, node: ast.Dict):
        self.stats['dicts'] += 1
        self.generic_visit(node)

    def visit_Set(self, node: ast.Set):
        self.stats['sets'] += 1
        self.generic_visit(node)

    def visit_Tuple(self, node: ast.Tuple):
        self.stats['tuples'] += 1
        self.generic_visit(node)


def count_comments_and_blanks(source_lines: List[str]) -> tuple[int, int]:
    """Count comment lines and blank lines."""
    comments = 0
    blanks = 0
    in_multiline_string = False
    multiline_delim = None

    for line in source_lines:
        stripped = line.strip()
        if not stripped:
            blanks += 1
            continue

        # Handle multiline strings (often used as docstrings)
        if '"""' in stripped or "'''" in stripped:
            if '"""' in stripped:
                delim = '"""'
            else:
                delim = "'''"

            count = stripped.count(delim)
            if count == 2:
                # Single line docstring like """doc"""
                comments += 1
                continue
            elif count == 1:
                if not in_multiline_string:
                    in_multiline_string = True
                    multiline_delim = delim
                    comments += 1
                elif delim == multiline_delim:
                    in_multiline_string = False
                    multiline_delim = None
                    comments += 1
                continue

        if in_multiline_string:
            comments += 1
            continue

        # Single line comment
        if stripped.startswith('#'):
            comments += 1
            continue

        # Inline comment
        if '#' in stripped:
            comments += 1

    return comments, blanks


def analyze_file(file_path: Path) -> Dict:
    """Analyze a single Python file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            source = f.read()
            source_lines = source.splitlines()

        tree = ast.parse(source, filename=str(file_path))
        analyzer = CodeAnalyzer(source_lines)
        analyzer.visit(tree)

        # Count line types
        total_lines = len(source_lines)
        comments, blanks = count_comments_and_blanks(source_lines)

        # Count docstrings separately
        docstring_finder = DocstringFinder()
        docstring_finder.visit(tree)

        return {
            'total_lines': total_lines,
            'code_lines': total_lines - comments - blanks,
            'comment_lines': comments,
            'blank_lines': blanks,
            'docstrings': docstring_finder.docstring_count,
            **analyzer.stats,
        }
    except (SyntaxError, UnicodeDecodeError) as e:
        print(f"Warning: Could not parse {file_path}: {e}")
        return None


class DocstringFinder(ast.NodeVisitor):
    """Find and count docstrings."""

    def __init__(self):
        self.docstring_count = 0

    def visit_Module(self, node: ast.Module):
        if (ast.get_docstring(node) is not None):
            self.docstring_count += 1
        self.generic_visit(node)

    def visit_ClassDef(self, node: ast.ClassDef):
        if (ast.get_docstring(node) is not None):
            self.docstring_count += 1
        self.generic_visit(node)

    def visit_FunctionDef(self, node: ast.FunctionDef):
        if (ast.get_docstring(node) is not None):
            self.docstring_count += 1
        self.generic_visit(node)

    def visit_AsyncFunctionDef(self, node: ast.AsyncFunctionDef):
        if (ast.get_docstring(node) is not None):
            self.docstring_count += 1
        self.generic_visit(node)


def scan_directory(root: Path) -> Dict:
    """Scan all Python files in directory."""
    all_stats = Counter()
    file_count = 0
    per_file_stats = []

    for file_path in root.rglob('*.py'):
        if should_ignore(file_path):
            continue

        stats = analyze_file(file_path)
        if stats:
            file_count += 1
            for key, value in stats.items():
                all_stats[key] += value
            per_file_stats.append((file_path, stats))

    return dict(all_stats), file_count, per_file_stats


def format_number(n: int) -> str:
    """Format number with thousands separator."""
    return f"{n:,}"


def print_stats(stats: Dict, file_count: int):
    """Print statistics in a nice format."""

    print("\n" + "=" * 60)
    print("           CODEBASE STATISTICS")
    print("=" * 60)

    print(f"\n📁 Files analyzed: {format_number(file_count)}")

    print("\n📏 LINES OF CODE")
    print("-" * 40)
    print(f"  Total lines:       {format_number(stats['total_lines'])}")
    print(f"  Code lines:        {format_number(stats['code_lines'])}")
    print(f"  Comment lines:     {format_number(stats['comment_lines'])}")
    print(f"  Blank lines:       {format_number(stats['blank_lines'])}")
    print(f"  Docstrings:        {format_number(stats['docstrings'])}")

    print("\n🏗️  STRUCTURE")
    print("-" * 40)
    print(f"  Classes:           {format_number(stats['classes'])}")
    print(f"  Functions:         {format_number(stats['functions'])}")
    print(f"  Async functions:   {format_number(stats['async_functions'])}")
    print(f"  Methods:           {format_number(stats['methods'])}")
    print(f"    - classmethods:  {format_number(stats['class_methods'])}")
    print(f"    - staticmethods: {format_number(stats['static_methods'])}")
    print(f"    - properties:    {format_number(stats['properties'])}")

    print("\n📥 IMPORTS")
    print("-" * 40)
    print(f"  Import statements: {format_number(stats['imports'])}")
    print(f"  From imports:      {format_number(stats['from_imports'])}")

    print("\n🔧 FUNCTIONS & METHODS")
    print("-" * 40)
    print(f"  Total arguments:   {format_number(stats['args'])}")
    print(f"  Keyword args:      {format_number(stats['kwargs'])}")
    print(f"  Lambda functions:  {format_number(stats['lambda_functions'])}")

    print("\n🎯 DATA STRUCTURES")
    print("-" * 40)
    print(f"  Lists:             {format_number(stats['lists'])}")
    print(f"  Dictionaries:      {format_number(stats['dicts'])}")
    print(f"  Sets:              {format_number(stats['sets'])}")
    print(f"  Tuples:            {format_number(stats['tuples'])}")
    print(f"  Comprehensions:    {format_number(stats['comprehensions'])}")

    print("\n🔄 CONTROL FLOW")
    print("-" * 40)
    print(f"  If statements:     {format_number(stats['if_statements'])}")
    print(f"  For loops:         {format_number(stats['for_loops'])}")
    print(f"  While loops:       {format_number(stats['while_loops'])}")
    print(f"  Try/except blocks: {format_number(stats['try_except_blocks'])}")
    print(f"  With statements:   {format_number(stats['with_statements'])}")

    print("\n📊 OTHER")
    print("-" * 40)
    print(f"  Function calls:    {format_number(stats['calls'])}")
    print(f"  Assignments:       {format_number(stats['assignments'])}")
    print(f"  Type annotated:    {format_number(stats['annotated_assignments'])}")
    print(f"  Decorators:        {format_number(stats['decorators'])}")
    print(f"  String literals:   {format_number(stats['strings'])}")
    print(f"  Number literals:   {format_number(stats['numbers'])}")

    # Averages per file
    if file_count > 0:
        print("\n📈 AVERAGES PER FILE")
        print("-" * 40)
        print(f"  Lines per file:    {stats['total_lines'] / file_count:.1f}")
        print(f"  Functions/file:    {stats['functions'] / file_count:.1f}")
        print(f"  Classes/file:      {stats['classes'] / file_count:.1f}")

    print("\n" + "=" * 60)


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description='Analyze Python codebase statistics using ast module.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Analyze current directory
  python analyze_code_stats.py

  # Analyze specific directory
  python analyze_code_stats.py /path/to/project

  # Ignore additional directories
  python analyze_code_stats.py --ignore tests scripts

  # Ignore specific files
  python analyze_code_stats.py --ignore-file setup.py config.py

  # Combine options
  python analyze_code_stats.py /path/to/project --ignore build dist --ignore-file __init__.py
        """
    )

    parser.add_argument(
        'path',
        nargs='?',
        default='.',
        help='Path to the directory to analyze (default: current directory)'
    )

    parser.add_argument(
        '--ignore', '-i',
        nargs='*',
        default=[],
        metavar='DIR',
        help='Additional directory names to ignore (e.g., tests scripts)'
    )

    parser.add_argument(
        '--ignore-file', '-f',
        nargs='*',
        default=[],
        metavar='FILE',
        help='File names to ignore (e.g., setup.py config.py)'
    )

    parser.add_argument(
        '--no-default-ignore',
        action='store_true',
        help='Do not use default ignore list (.venv, __pycache__, etc.)'
    )

    return parser.parse_args()


def main():
    """Main entry point."""
    args = parse_args()

    # Update global ignore sets based on CLI args
    global IGNORE_DIRS, IGNORE_FILES

    if args.no_default_ignore:
        IGNORE_DIRS = set()
    else:
        IGNORE_DIRS = set(DEFAULT_IGNORE_DIRS)

    # Add user-specified directories to ignore
    if args.ignore:
        IGNORE_DIRS.update(args.ignore)

    # Add user-specified files to ignore
    IGNORE_FILES.update(args.ignore_file)

    # Get the path to analyze
    root = Path(args.path).resolve()

    if not root.exists():
        print(f"❌ Error: Path does not exist: {root}")
        return

    if not root.is_dir():
        print(f"❌ Error: Path is not a directory: {root}")
        return

    print(f"🔍 Analyzing Python codebase in: {root}")

    if IGNORE_DIRS:
        print(f"🚫 Ignoring directories: {', '.join(sorted(IGNORE_DIRS))}")
    if IGNORE_FILES:
        print(f"🚫 Ignoring files: {', '.join(sorted(IGNORE_FILES))}")

    print("⏳ Scanning files...")

    stats, file_count, per_file_stats = scan_directory(root)

    if file_count == 0:
        print("⚠️  No Python files found!")
        return

    print_stats(stats, file_count)

    # Optionally show top files by line count
    print("\n📋 TOP 10 FILES BY LINE COUNT")
    print("-" * 40)
    top_files = sorted(per_file_stats, key=lambda x: x[1]['total_lines'], reverse=True)[:10]
    for path, file_stats in top_files:
        try:
            rel_path = path.relative_to(root)
        except ValueError:
            # path is not relative to root (can happen with symlinks)
            rel_path = path
        print(f"  {format_number(file_stats['total_lines']):>6}  {rel_path}")


if __name__ == '__main__':
    main()
