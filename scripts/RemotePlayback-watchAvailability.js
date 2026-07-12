The following example demonstrates a player with custom controls that support remote playback. 
Initially the button used to select a device is hidden:

HTML
Copy this text to Clipboard --- 
<video id="videoElement" src="https://cdn.free-stock.video/272021/sand-blue-nature-sand-waves-ocean-wave-83350-small.mp4" type="video/mp4" autoplay>
  <source src="https://cdn.free-stock.video/272021/sand-blue-nature-sand-waves-ocean-wave-83350-small.mp4" type="video/ogg" autoplay>
  <button id="deviceBtn" style="display: none;">Pick device</button>
</video>
<br>

The RemotePlayback.watchAvailability() method is used to watch for 
available remote playback devices. If a device is available, 
use the callback to show the button.

<script>
const deviceBtn = document.getElementById("deviceBtn");
const videoElem = document.getElementById("videoElement");

function availabilityCallback(available) {
  // Show or hide the device picker button depending on device availability.
  deviceBtn.style.display = available ? "inline" : "none";
  console.log('Did check');
  videoElem.play;
}

videoElem.remote.watchAvailability(availabilityCallback).catch(() => {
	 console.log('display inline');
  /* If the device cannot continuously watch available,
  show the button to allow the user to try to prompt for a connection.*/
  deviceBtn.style.display = "inline";
   
	
});

</script>