package com.android.internal.telephony;

import android.content.Context;

public class A11ulRIL extends RIL implements CommandsInterface {

// RIL customization for Desire 510 (Cricket variant)

    public A11ulRIL(Context context, int networkMode, int cdmaSubscription) {
        super(context, networkMode, cdmaSubscription, null);
        mQANElements = 5;
    }

    public A11ulRIL(Context context, int preferredNetworkType,
            int cdmaSubscription, Integer instanceId) {
        super(context, preferredNetworkType, cdmaSubscription, instanceId);
        mQANElements = 5;
    }

}
