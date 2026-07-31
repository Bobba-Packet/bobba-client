package com.sulake.habbo.window.utils.traxmachine
{
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.events.TimerEvent;
   
   public class TraxMachinePlayer
   {
      
      public static const CELL_MS:int = 2000;
      
      private var _assets:TraxMachineAssets;
      
      private var _catalog:TraxMachineCatalog;
      
      private var _channels:Vector.<SoundChannel>;
      
      private var _sounds:Vector.<Sound>;
      
      private var _timer:Timer;
      
      private var _playing:Boolean = false;
      
      private var _playhead:int = 0;
      
      private var _firstTick:Boolean = true;
      
      private var _onTick:Function;
      
      private var _previewSound:Sound;
      
      private var _previewChannel:SoundChannel;
      
      private var _cache:Dictionary;
      
      public function TraxMachinePlayer(assets:TraxMachineAssets, catalog:TraxMachineCatalog)
      {
         super();
         _assets = assets;
         _catalog = catalog;
         _channels = new Vector.<SoundChannel>(4,true);
         _sounds = new Vector.<Sound>(4,true);
         _cache = new Dictionary();
         _timer = new Timer(CELL_MS);
         _timer.addEventListener(TimerEvent.TIMER,onTimer);
      }
      
      public function get playing() : Boolean
      {
         return _playing;
      }
      
      public function get playhead() : int
      {
         return _playhead;
      }
      
      public function set playhead(value:int) : void
      {
         _playhead = value < 0 ? 0 : value;
      }
      
      public function set onTick(value:Function) : void
      {
         _onTick = value;
      }
      
      public function preview(songId:int) : void
      {
         stopPreview();
         var song:Object = _catalog.getSong(songId);
         if(song == null)
         {
            return;
         }
         var sound:Sound = getCachedSound(int(song.id),String(song.file));
         _previewSound = sound;
         _previewChannel = sound.play(0);
      }
      
      public function stopPreview() : void
      {
         if(_previewChannel != null)
         {
            _previewChannel.stop();
            _previewChannel = null;
         }
      }
      
      public function play(readCell:Function) : void
      {
         stopPreview();
         _playing = true;
         _firstTick = true;
         _onTick = readCell;
         _timer.reset();
         _timer.start();
         tick();
      }
      
      public function pause() : void
      {
         _playing = false;
         _timer.stop();
         stopAllLayers();
      }
      
      public function stop() : void
      {
         pause();
         _playhead = 0;
         _firstTick = true;
      }
      
      public function dispose() : void
      {
         stop();
         stopPreview();
         _timer.removeEventListener(TimerEvent.TIMER,onTimer);
         _timer = null;
         _cache = null;
      }
      
      private function onTimer(e:TimerEvent) : void
      {
         tick();
      }
      
      private function tick() : void
      {
         if(!_firstTick)
         {
            _playhead++;
         }
         _firstTick = false;
         if(_onTick != null)
         {
            _onTick(_playhead);
         }
      }
      
      public function triggerLayer(layer:int, songId:int, seekSeconds:Number = 0) : void
      {
         if(layer < 0 || layer > 3)
         {
            return;
         }
         var song:Object = _catalog.getSong(songId);
         if(song == null)
         {
            return;
         }
         if(_channels[layer] != null)
         {
            _channels[layer].stop();
            _channels[layer] = null;
         }
         var sound:Sound = getCachedSound(songId,String(song.file));
         _sounds[layer] = sound;
         var startMs:Number = seekSeconds * 1000;
         _channels[layer] = sound.play(startMs);
      }
      
      public function stopAllLayers() : void
      {
         var i:int = 0;
         for(i = 0; i < 4; i++)
         {
            if(_channels[i] != null)
            {
               _channels[i].stop();
               _channels[i] = null;
            }
         }
      }
      
      private function getCachedSound(songId:int, fileName:String) : Sound
      {
         var url:String = null;
         if(_cache[songId] != null)
         {
            return _cache[songId] as Sound;
         }
         url = _assets.soundUrl(fileName);
         if(url == null || url.length == 0)
         {
            return new Sound();
         }
         var sound:Sound = new Sound();
         sound.load(new URLRequest(url));
         _cache[songId] = sound;
         return sound;
      }
   }
}
