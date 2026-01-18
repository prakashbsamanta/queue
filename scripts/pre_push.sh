#!/bin/bash

# Pre-push hook to ensure code quality

echo "🚀 Running pre-push checks..."

# 1. Analyze
echo "🔍 Running Flutter Analyze..."
flutter analyze
ANALYZE_EXIT_CODE=$?

if [ $ANALYZE_EXIT_CODE -ne 0 ]; then
  echo "❌ Flutter Analyze failed. Please fix the issues before pushing."
  exit 1
fi

echo "✅ Flutter Analyze passed."

# 2. Test
echo "🧪 Running Flutter Tests..."
flutter test
TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -ne 0 ]; then
  echo "❌ Flutter Test failed. Please fix the tests before pushing."
  exit 1
fi

echo "✅ Flutter Tests passed."

echo "🎉 All checks passed. Pushing code..."
exit 0
