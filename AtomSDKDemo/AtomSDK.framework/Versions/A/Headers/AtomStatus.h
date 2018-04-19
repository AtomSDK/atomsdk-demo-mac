//
//  AtomStatus.h
//  AtomSDK
//
//  Copyright © 2017 Atom. All rights reserved.
//

#ifndef AtomStatus_h
#define AtomStatus_h

typedef NS_ENUM (NSInteger, AtomVPNState) {
    /*! @const AtomStatusInvalid The VPN is not configured. 0 */
    AtomStatusInvalid,
    /*! @const AtomStatusDisconnected The VPN is disconnected. 1 */
    AtomStatusDisconnected,
    /*! @const AtomStatusConnecting The VPN is connecting. 2 */
    AtomStatusConnecting,
    /*! @const AtomStatusConnected The VPN is connected. 3 */
    AtomStatusConnected,
    /*! @const AtomStatusReasserting The VPN is reconnecting following loss of underlying network connectivity. 4 */
    AtomStatusReasserting,
    /*! @const AtomStatusDisconnecting The VPN is disconnecting. 5 */
    AtomStatusDisconnecting,
    /*! @const AtomStatusValidation The VPN is Validat. 6 */
    AtomStatusValidating,
    /*! @const GeneratingCredentials The VPN is disconnecting. 7 */
    AtomStatusGeneratingCredentials,
    /*! @const AtomStatusGettingFastestServer The VPN is disconnecting. 8 */
    AtomStatusGettingFastestServer,
    /*! @const OptimizingConnection The VPN is disconnecting. 9 */
    AtomStatusOptimizingConnection,
    /*! @const AtomStatusAuthenticating The VPN is AtomStatusAuthenticating. 10 */
    AtomStatusAuthenticating,
    /*! @const AtomStatusVerifyingHostName The VPN is AtomStatusVerifyingHostName. 11 */
    AtomStatusVerifyingHostName
};

typedef NS_ENUM (NSInteger, AtomVPNStatus) {

    /*! @const DISCONNECTED The VPN is disconnected. */
    DISCONNECTED,
    /*! @const CONNECTING The VPN is connecting. */
    CONNECTING,
    /*! @const CONNECTED The VPN is connected. */
    CONNECTED,

};


typedef void (^StateDidChangedHandler)(AtomVPNState status);

#endif /* AtomStatus_h */
