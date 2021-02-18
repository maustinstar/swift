// RUN: %empty-directory(%t)
// RUN: %target-build-swift-dylib(%t/%target-library-name(NonresilientClass)) %S/Inputs/class_open-1instance-void_to_void.swift -Xfrontend -enable-experimental-concurrency -module-name NonresilientClass -emit-module -emit-module-path %t/NonresilientClass.swiftmodule
// RUN: %target-codesign %t/%target-library-name(NonresilientClass)
// RUN: %target-build-swift -Xfrontend -enable-experimental-concurrency %S/Inputs/class_open-1instance-void_to_void.swift -emit-ir -I %t -L %t -lNonresilientClass -parse-as-library -module-name main | %FileCheck %S/Inputs/class_open-1instance-void_to_void.swift --check-prefix=CHECK-LL
// RUN: %target-build-swift -Xfrontend -enable-experimental-concurrency %s -parse-as-library -module-name main -o %t/main -I %t -L %t -lNonresilientClass %target-rpath(%t) 
// RUN: %target-codesign %t/main
// RUN: %target-run %t/main %t/%target-library-name(NonresilientClass) | %FileCheck %s

// REQUIRES: executable_test
// REQUIRES: swift_test_mode_optimize_none
// REQUIRES: concurrency
// UNSUPPORTED: use_os_stdlib
// XFAIL: windows

import _Concurrency
import NonresilientClass

class D : C {
}

// CHECK: entering call_f
// CHECK: entering f
// CHECK: D
// CHECK: main.D
// CHECK: exiting f
// CHECK: exiting call_f
@main struct Main {
  static func main() async {
    let c = D()
    await call_f(c)
  }
}
