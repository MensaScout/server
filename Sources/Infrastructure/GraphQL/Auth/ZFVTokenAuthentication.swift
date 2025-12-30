import Vapor

struct ZFVTokenAuthentication: APIAuthentication {
    let token: String
    
    func apply(to headers: inout HTTPHeaders) {
        headers.add(name: "api-key", value: token)
    }
}
