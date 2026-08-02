package com.sulake.habbo.window.utils.bobba
{
   // Pure AS3 SHA-256 + HMAC-SHA256 for Bobba backend handshake.
   public class BobbaCrypto
   {
      
      private static const K:Array = [
         0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
         0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
         0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
         0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
         0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
         0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
         0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
         0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
      ];
      
      public function BobbaCrypto()
      {
         super();
      }
      
      public static function hmacSha256Hex(key:String, message:String) : String
      {
         return bytesToHex(hmacSha256(utf8Bytes(key), utf8Bytes(message)));
      }
      
      public static function hmacSha256(key:Array, message:Array) : Array
      {
         var blockSize:int = 64;
         if(key.length > blockSize)
         {
            key = sha256(key);
         }
         while(key.length < blockSize)
         {
            key.push(0);
         }
         var oKey:Array = [];
         var iKey:Array = [];
         var i:int = 0;
         for(i = 0; i < blockSize; i++)
         {
            oKey[i] = int(key[i]) ^ 0x5c;
            iKey[i] = int(key[i]) ^ 0x36;
         }
         return sha256(oKey.concat(sha256(iKey.concat(message))));
      }
      
      public static function sha256Hex(message:String) : String
      {
         return bytesToHex(sha256(utf8Bytes(message)));
      }
      
      public static function sha256(message:Array) : Array
      {
         var bitLen:uint = message.length * 8;
         var bytes:Array = message.concat();
         bytes.push(0x80);
         while(bytes.length % 64 != 56)
         {
            bytes.push(0);
         }
         bytes.push(0);
         bytes.push(0);
         bytes.push(0);
         bytes.push(0);
         bytes.push(bitLen >>> 24 & 255);
         bytes.push(bitLen >>> 16 & 255);
         bytes.push(bitLen >>> 8 & 255);
         bytes.push(bitLen & 255);
         
         var h0:uint = 0x6a09e667;
         var h1:uint = 0xbb67ae85;
         var h2:uint = 0x3c6ef372;
         var h3:uint = 0xa54ff53a;
         var h4:uint = 0x510e527f;
         var h5:uint = 0x9b05688c;
         var h6:uint = 0x1f83d9ab;
         var h7:uint = 0x5be0cd19;
         
         var offset:int = 0;
         var w:Array = new Array(64);
         var t:int = 0;
         var a:uint = 0;
         var b:uint = 0;
         var c:uint = 0;
         var d:uint = 0;
         var e:uint = 0;
         var f:uint = 0;
         var g:uint = 0;
         var h:uint = 0;
         var s0:uint = 0;
         var s1:uint = 0;
         var ch:uint = 0;
         var maj:uint = 0;
         var temp1:uint = 0;
         var temp2:uint = 0;
         
         while(offset < bytes.length)
         {
            for(t = 0; t < 16; t++)
            {
               w[t] = bytes[offset] << 24 | bytes[offset + 1] << 16 | bytes[offset + 2] << 8 | bytes[offset + 3];
               offset += 4;
            }
            for(t = 16; t < 64; t++)
            {
               s0 = rotr(w[t - 15],7) ^ rotr(w[t - 15],18) ^ w[t - 15] >>> 3;
               s1 = rotr(w[t - 2],17) ^ rotr(w[t - 2],19) ^ w[t - 2] >>> 10;
               w[t] = w[t - 16] + s0 + w[t - 7] + s1 & 0xffffffff;
            }
            a = h0;
            b = h1;
            c = h2;
            d = h3;
            e = h4;
            f = h5;
            g = h6;
            h = h7;
            for(t = 0; t < 64; t++)
            {
               s1 = rotr(e,6) ^ rotr(e,11) ^ rotr(e,25);
               ch = e & f ^ ~e & g;
               temp1 = h + s1 + ch + uint(K[t]) + uint(w[t]) & 0xffffffff;
               s0 = rotr(a,2) ^ rotr(a,13) ^ rotr(a,22);
               maj = a & b ^ a & c ^ b & c;
               temp2 = s0 + maj & 0xffffffff;
               h = g;
               g = f;
               f = e;
               e = d + temp1 & 0xffffffff;
               d = c;
               c = b;
               b = a;
               a = temp1 + temp2 & 0xffffffff;
            }
            h0 = h0 + a & 0xffffffff;
            h1 = h1 + b & 0xffffffff;
            h2 = h2 + c & 0xffffffff;
            h3 = h3 + d & 0xffffffff;
            h4 = h4 + e & 0xffffffff;
            h5 = h5 + f & 0xffffffff;
            h6 = h6 + g & 0xffffffff;
            h7 = h7 + h & 0xffffffff;
         }
         
         return uintToBytes(h0).concat(uintToBytes(h1),uintToBytes(h2),uintToBytes(h3),uintToBytes(h4),uintToBytes(h5),uintToBytes(h6),uintToBytes(h7));
      }
      
      private static function rotr(value:uint, bits:int) : uint
      {
         return value >>> bits | value << 32 - bits;
      }
      
      private static function uintToBytes(value:uint) : Array
      {
         return [value >>> 24 & 255,value >>> 16 & 255,value >>> 8 & 255,value & 255];
      }
      
      public static function utf8Bytes(value:String) : Array
      {
         var out:Array = [];
         var i:int = 0;
         var code:int = 0;
         for(i = 0; i < value.length; i++)
         {
            code = value.charCodeAt(i);
            if(code < 0x80)
            {
               out.push(code);
            }
            else if(code < 0x800)
            {
               out.push(0xc0 | code >> 6);
               out.push(0x80 | code & 0x3f);
            }
            else
            {
               out.push(0xe0 | code >> 12);
               out.push(0x80 | code >> 6 & 0x3f);
               out.push(0x80 | code & 0x3f);
            }
         }
         return out;
      }
      
      public static function bytesToHex(bytes:Array) : String
      {
         var hex:String = "";
         var i:int = 0;
         var b:int = 0;
         for(i = 0; i < bytes.length; i++)
         {
            b = int(bytes[i]) & 255;
            if(b < 16)
            {
               hex += "0";
            }
            hex += b.toString(16);
         }
         return hex;
      }
      
      public static function randomHex(byteCount:int) : String
      {
         var out:String = "";
         var i:int = 0;
         var n:int = 0;
         for(i = 0; i < byteCount; i++)
         {
            n = int(Math.random() * 256);
            if(n < 16)
            {
               out += "0";
            }
            out += n.toString(16);
         }
         return out;
      }
   }
}
