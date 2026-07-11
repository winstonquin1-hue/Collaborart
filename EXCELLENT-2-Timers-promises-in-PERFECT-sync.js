 <p>Basic
     <div id="base">base</div> 
	<br>concurrent
	<div id="concurrent1">concurrent1</div>
   <div id="concurrent2">concurrent2</div>	
	 <p> Log
     <div id="logResults0">logResults1</div> 
     <div id="logResults1">logResults2</div> 
  <br>Awaits
   <div id="awaitslow">awaitslow</div>
     <div id="awaitfast">awaitslow</div>
	<br>After run
	<div id="After2Seconds"></div>
    <div id="After1Second">faststatus</div>
	</p>
<script>
function resolveAfter2Seconds() {
 // console.log("starting slow promise");
    document.getElementById("After2Seconds").innerHTML ="starting slow promise";
  return new Promise((resolve) => {
    setTimeout(() => {
		
      resolve("slow");
	   document.getElementById("After2Seconds").innerHTML ="slow promise is done";
    //  console.log("slow promise is done");
	  
    }, 6000);
  });
}

function resolveAfter1Second() {
 // console.log("starting fast promise");
  document.getElementById("After1Second").innerHTML ="starting fast promise";
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve("fast");
      console.log("fast promise is done");
	   document.getElementById("After1Second").innerHTML ="fast promise is done";
    }, 3000);
  });
}

async function sequentialStart() {
  //console.log("== sequentialStart starts ==");
  document.getElementById("base").innerHTML ="== sequential Start starts ==";
  // 1. Start a timer, log after it's done
  const slow = resolveAfter2Seconds();
 // console.log(await slow);
  document.getElementById("awaitslow").innerHTML = await slow;// not console.log waits for it
  // 2. Start the next timer after waiting for the previous one
  const fast = resolveAfter1Second();
  console.log(await fast);
  document.getElementById("awaitfast").innerHTML = await fast;
  //console.log("== sequentialStart done ==");
  document.getElementById("base").innerHTML ="== sequential Start done ==";
}

async function sequentialWait() {
 // console.log("== sequentialWait starts ==");
  document.getElementById("base").innerHTML ="== sequential Wait starts ==";
  // 1. Start two timers without waiting for each other
  const slow = resolveAfter2Seconds();
  const fast = resolveAfter1Second();

  // 2. Wait for the slow timer to complete, and then log the result
 // console.log(await slow);
  document.getElementById("awaitslow").innerHTML = await low;// not console.log waits for it
  // 3. Wait for the fast timer to complete, and then log the result
 // console.log(await fast);
document.getElementById("awaitfast").innerHTML = await fast;
  console.log("== sequentialWait done ==");
   document.getElementById("base").innerHTML ="== sequential Wait done ==";
}

async function concurrent1() {
//  console.log("== concurrent1 starts ==");  
 document.getElementById("concurrent1").innerHTML ="== concurrent 1 starts ==";
  // 1. Start two timers concurrently and wait for both to complete
  const results = await Promise.all([
    resolveAfter2Seconds(),
    resolveAfter1Second(),
  ]);
  // 2. Log the results together
 console.log(results[0]);
  document.getElementById("logResults0").innerHTML ="Results 0: "+results[0];
  
//  console.log(results[1]);
 document.getElementById("logResults1").innerHTML ="Results 1: "+ results[1];
 
 // console.log("== concurrent1 done ==");
  document.getElementById("concurrent1").innerHTML ="== concurrent 1 done ==";
}

async function concurrent2() {
  //console.log("== concurrent2 starts ==");
 document.getElementById("concurrent2").innerHTML ="== concurrent 2 starts ==";
  // 1. Start two timers concurrently, log immediately after each one is done
  await Promise.all([
    (async () =>  document.getElementById("concurrent2").innerHTML =(await resolveAfter2Seconds()))(),
    (async () => document.getElementById("concurrent1").innerHTML =(await resolveAfter1Second()))(),
  ]);
  //console.log("== concurrent2 done ==");
  document.getElementById("concurrent2").innerHTML ="== concurrent 2 done ==";
}

sequentialStart(); // after 2 seconds, logs "slow", then after 1 more second, "fast"

// wait above to finish
setTimeout(sequentialWait, 8000); // after 2 seconds, logs "slow" and then "fast"

// wait again
setTimeout(concurrent1, 7000); // same as sequentialWait

// wait again
setTimeout(concurrent2, 20000); // after 1 second, logs "fast", then after 1 more second, "slow"

function resolveAfter2Seconds(x) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(x);
    }, 2000);
  });
}

// async function expression assigned to a variable
const add = async function (x) {
  const a = await resolveAfter2Seconds(20);
  const b = await resolveAfter2Seconds(30);
  return x + a + b;
};

add(10).then((v) => {
	
 // console.log(v); // prints 60 after 4 seconds.
      document.getElementById("base").innerHTML ="Add 10: "+v;
});

// async function expression used as an IIFE
(async function (x) {
  const p1 = resolveAfter2Seconds(20);
  const p2 = resolveAfter2Seconds(30);
  return x + (await p1) + (await p2);
})(10).then((v) => {
 // console.log(v); // prints 60 after 2 seconds.
    document.getElementById("base").innerHTML ="acync function: " +v;
});

</script>


