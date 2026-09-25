#!/usr/bin/env bash

function register_clang_version {
  local VERSION=$1
  local PRIORITY=$2

  update-alternatives --force \
    --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-${VERSION} ${PRIORITY} \
    --slave /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-${VERSION} \
    --slave /usr/bin/llvm-as llvm-as /usr/bin/llvm-as-${VERSION} \
    --slave /usr/bin/llvm-bcanalyzer llvm-bcanalyzer /usr/bin/llvm-bcanalyzer-${VERSION} \
    --slave /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-${VERSION} \
    --slave /usr/bin/llvm-diff llvm-diff /usr/bin/llvm-diff-${VERSION} \
    --slave /usr/bin/llvm-dis llvm-dis /usr/bin/llvm-dis-${VERSION} \
    --slave /usr/bin/llvm-dwarfdump llvm-dwarfdump /usr/bin/llvm-dwarfdump-${VERSION} \
    --slave /usr/bin/llvm-extract llvm-extract /usr/bin/llvm-extract-${VERSION} \
    --slave /usr/bin/llvm-link llvm-link /usr/bin/llvm-link-${VERSION} \
    --slave /usr/bin/llvm-mc llvm-mc /usr/bin/llvm-mc-${VERSION} \
    --slave /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-${VERSION} \
    --slave /usr/bin/llvm-objdump llvm-objdump /usr/bin/llvm-objdump-${VERSION} \
    --slave /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-${VERSION} \
    --slave /usr/bin/llvm-readobj llvm-readobj /usr/bin/llvm-readobj-${VERSION} \
    --slave /usr/bin/llvm-rtdyld llvm-rtdyld /usr/bin/llvm-rtdyld-${VERSION} \
    --slave /usr/bin/llvm-size llvm-size /usr/bin/llvm-size-${VERSION} \
    --slave /usr/bin/llvm-stress llvm-stress /usr/bin/llvm-stress-${VERSION} \
    --slave /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-${VERSION} \
    --slave /usr/bin/llvm-tblgen llvm-tblgen /usr/bin/llvm-tblgen-${VERSION}

  update-alternatives --force \
    --install /usr/bin/clang clang /usr/bin/clang-${VERSION} ${PRIORITY} \
    --slave /usr/bin/clang++ clang++ /usr/bin/clang++-${VERSION} \
    --slave /usr/bin/asan_symbolize asan_symbolize /usr/bin/asan_symbolize-${VERSION} \
    --slave /usr/bin/c-index-test c-index-test /usr/bin/c-index-test-${VERSION} \
    --slave /usr/bin/clang-check clang-check /usr/bin/clang-check-${VERSION} \
    --slave /usr/bin/clang-cl clang-cl /usr/bin/clang-cl-${VERSION} \
    --slave /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-${VERSION} \
    --slave /usr/bin/clang-format clang-format /usr/bin/clang-format-${VERSION} \
    --slave /usr/bin/clang-format-diff clang-format-diff /usr/bin/clang-format-diff-${VERSION} \
    --slave /usr/bin/clang-include-fixer clang-include-fixer /usr/bin/clang-include-fixer-${VERSION} \
    --slave /usr/bin/clang-offload-bundler clang-offload-bundler /usr/bin/clang-offload-bundler-${VERSION} \
    --slave /usr/bin/clang-query clang-query /usr/bin/clang-query-${VERSION} \
    --slave /usr/bin/clang-rename clang-rename /usr/bin/clang-rename-${VERSION} \
    --slave /usr/bin/clang-reorder-fields clang-reorder-fields /usr/bin/clang-reorder-fields-${VERSION} \
    --slave /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${VERSION} \
    --slave /usr/bin/lldb lldb /usr/bin/lldb-${VERSION} \
    --slave /usr/bin/lldb-server lldb-server /usr/bin/lldb-server-${VERSION} \
    --slave /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-${VERSION}
}

register_clang_version $1 $2
