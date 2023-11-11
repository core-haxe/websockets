package ws.impl;

import ws.impl.uuid.Uuid;

class Util {
    public static function generateUUID():String {
        return Uuid.v1();
    }
}