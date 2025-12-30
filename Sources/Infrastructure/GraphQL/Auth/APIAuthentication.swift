import Vapor

protocol APIAuthentication {
    func apply(to headers: inout HTTPHeaders)
}
