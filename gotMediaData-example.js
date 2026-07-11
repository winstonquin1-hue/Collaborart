<body>
<!-- <video autoplay >  -->
 <video id="recording" width="160" height="120" controls="" autoplay></video> 
	
  <p>Here <video id="x" autoplay> </p>
    
<div id="dataDiv">   </div>
<script>
  var recordedChunks = [];     
   let recordedBlob;
  let recording = document.getElementById("recording");
         
		 document.addEventListener("x", gotMediadata, {capture: true});
	      document.body.addEventListener("x", gotMediadata); 
	       var ev = new Event("x", {bubbles:true})


  function gotMedia(stream) {
    // |video| shows a live view of the captured MediaStream.
    var video = document.querySelector('video');
      //  video.src = URL.createObjectURL(stream);
         video.srcObject = stream;
		//  console.log(' Recorded chunk of size ' + recordedChunks); 
    var recorder = null;

    try {
      recorder = new MediaRecorder(stream, {mimeType: "video/webm"});	   
    } catch (e) {
      console.error('Exception while creating MediaRecorder: ' + e);
      return;
    }
    recorder.ondataavailable = (event) => {
     // console.log(' Recorded chunk of size ' + event.data.size + "Bytes  " + recordedChunks.push(event.data));
     //  document.getElementById("x").dispatchEvent(ev)   
	 recordedChunks.push(event.data);
	 
       let recordedBlob = new Blob(recordedChunks, { type: "video/webm" });
        recording.src = URL.createObjectURL(recordedBlob);
        document.getElementById("x").dispatchEvent(ev)  
		recorder.start(5000);

        
	   };    
  }


  function gotMediadata(e) {
  alert(stream)
      
       // recording.src = URL.createObjectURL(recordedBlob);
     document.getElementById("x").innerHTML = recordedBlob;//recording.src;   
 // console.log('stream  x' + ev+ " .....  "+recordedChunks.push(event.data));
  }
  /*
   function gotMediadataDiv(evdataDiv) {
//  alert(stream)
      
       // recording.src = URL.createObjectURL(recordedBlob);
     document.getElementById("dataDiv").innerHTML = evdataDiv;//recordedBlob;//recording.src;   
  console.log('evdataDiv ' + evdataDiv+ " .....  "+recordedChunks.push(event.data));
  } */
  
 /*  function test(e) {
     //--needs to have a debugger debug(e.target, e.currentTarget, e.eventPhase)
	 //     console.log(e.target, e.currentTarget, e.eventPhase)
     // alert(e.eventPhase)
   }*/
//----------
  navigator.mediaDevices.getUserMedia({video: true, audio: true})
     .then(gotMedia)
      .catch(e => { console.error('getUserMedia() failed: ' + e); });
</script>
</body>