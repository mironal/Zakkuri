import RxSwift
import UIKit

/*
 protocol A_Protocol {// public
 var one: String { get }
 var two: String { get }
 }

 struct A { // internal
 let one: Bool = true
 let two: Bool = true
 let yobenai: Bool = true
 }

 extension A: A_Protocol {}

 // 此処から先の世界は A_Protocol の情報だけで良い世界

 func something(_ a: A_Protocol) {

 }
 */

// something をテストする

// A を one, two, yobenai がそれぞれど色んなパターンについてテストが必要 2^3
// A_Protocol だと 2^2 のパターンが必要

protocol A_ModelProtocol {}
protocol B_ModelProtocol {}
protocol C_ModelProtocol {}

class A_Model: A_ModelProtocol {}
class B_Model: B_ModelProtocol {}
class C_Model: C_ModelProtocol {}

struct Models {
    let a: A_ModelProtocol
    let b: B_ModelProtocol
    let c: C_ModelProtocol
}

// ## 次回

//// ↑ Model層

/// ↓ ViewModel 層
