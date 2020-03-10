import Foundation
import MultipeerConnectivity

protocol SharingServiceDelegate: class {
    func connectedDevicesChanged(connectedDevices: [String])
    func didRecieveError(error: Error)
}

class SharingService : NSObject {

    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let sharingServiceType = "sharing-service"

    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceBrowser : MCNearbyServiceBrowser

    private var advertiserAssistant: MCAdvertiserAssistant?

    weak var delegate : SharingServiceDelegate?

    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()

    override init() {
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: sharingServiceType)

        super.init()

        self.serviceBrowser.delegate = self
    }

    deinit {
        self.advertiserAssistant?.stop()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    func startHosting() {
        advertiserAssistant = MCAdvertiserAssistant(serviceType: sharingServiceType, discoveryInfo: nil, session: session)
        advertiserAssistant?.start()
    }

    func sendImage(image: UIImage) {
        if session.connectedPeers.count > 0 {
            if let imageData = image.pngData() {
                do {
                    try session.send(imageData, toPeers: session.connectedPeers, with: .reliable)
                } catch let error {
                    delegate?.didRecieveError(error: error)
                }
            }
        }
    }
}

extension SharingService: MCAdvertiserAssistantDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    }
}

extension SharingService : MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }

}

extension SharingService : MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }

}
