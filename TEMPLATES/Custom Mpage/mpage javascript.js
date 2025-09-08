function getEvents(){
	// Call functions to format html and populate sections
	patientInfoTable(); 
	allergyInfoTable();
	docTable();
}

//Add async for Edge Compatibility******************
async function patientInfoTable(){
    //Added for Edge Compatibility ***Start********************
    let patPromise = new Promise(function(resolve) {
    //Added for Edge Compatibility ***End********************
	// Initialize the request object
	var patInfo = new XMLCclRequest();

	// Get the response
	patInfo.onreadystatechange = function () {
		// 4->Completed, 200->Success for XMLCCLREQUEST
		if (patInfo.readyState == 4 && patInfo.status == 200) {
            var msgPatient = patInfo.responseText;
			if (msgPatient != undefined && msgPatient != null && msgPatient > " ") {
				var jsonPatient = eval('(' + msgPatient + ')');
			}
			if (jsonPatient){
				var tableBody = ["<table>"];
				for (var i=0,aLen=jsonPatient.PATINFO.INFO.length;i<aLen;i++) {
					var patObj = jsonPatient.PATINFO.INFO[i]; 

					tableBody.push(    
					"<tr>",
						"<td class='col1'>", patObj.LABEL,"</td>",
						"<td class='col2' title=\"",patObj.HOVER,"\">",patObj.DATA,"</td>",
					"</tr>");
				}  // end for

				// Close the table
				tableBody.push("</table>");

			// Insert the table into the patient information section
			document.getElementById('patientInfoTable').innerHTML  = tableBody.join("");
			
			var link = tabLink("Custom Patient Information","Patient Information","$APP_APPNAME$");

			// Insert the link into the patient information section header
			document.getElementById('patHeader').innerHTML  = link;

            //Added for Edge Compatibility ***Start********************
            resolve("Finished getting Patient data");            
            //Added for Edge Compatibility ***End********************                     

            //Initialize the col2 elements as hovers
			$.reInitPopUps('patientInfoTable');
			} //if (jsonPatient)            
		};   //if
	} //function

	//  Call the ccl progam and send the parameter string
    //Add ,true for Edge Compatibility******************
	patInfo.open('GET', "JW1_MPAGE_PATIENTINFO",true);
	//patInfo.send("MINE, $PAT_Personid$"); 
	allInfo.send("MINE, "+MPAGE_REC.PERSON_ID+".0");
	//patInfo.send("MINE,1416145.00"); // use this line while testing in dvdev
    //Added for Edge Compatibility ***Start********************
    });
    console.log("starting to wait for promise");        
    var waitForPromise = await patPromise;   
    console.log(waitForPromise); 
    //Added for Edge Compatibility ***End********************
	// return;
}

//Add async for Edge Compatibility******************
async function allergyInfoTable(){
    //Added for Edge Compatibility ***Start********************
    let algPromise = new Promise(function(resolve) {
    //Added for Edge Compatibility ***End********************

	// Initialize the request object
	var allInfo = new XMLCclRequest();

	// Get the response
	allInfo.onreadystatechange = function () {
		if (allInfo.readyState == 4 && allInfo.status == 200) {
			var msgAllergy = allInfo.responseText;

			if (msgAllergy != undefined && msgAllergy != null && msgAllergy > " ") {
				var jsonAllergy = eval('(' + msgAllergy + ')');
			}

			if (jsonAllergy){
				var tableBody = ["<table>"];
				for (var i=0,aLen=jsonAllergy.ALLERGIES.ALLERGY.length;i<aLen;i++) {
					var allergyObj = jsonAllergy.ALLERGIES.ALLERGY[i]; 

					tableBody.push(    
					"<tr class='allergyRow'>",
						"<td class='col1'>", allergyObj.ALLERGY_NAME,"</td>",
						"<td class='col2'>", allergyObj.ALLERGY_REACTION,"</td>",
					"</tr>");
				}  // end for

				// Close the table
				tableBody.push("</table>");

				// Insert the table into the allergy section
				document.getElementById('allergyTable').innerHTML  = tableBody.join("")
                //Added for Edge Compatibility ***Start********************
                resolve("Finished getting Allergy data");            
                //Added for Edge Compatibility ***End********************
				//  This will do alternate row shading with jquery
				$('tr.allergyRow:odd').addClass('odd_row');
			} //if (jsonAllergy)
		};   //if
	} //function

	//  Call the ccl progam and send the parameter string
    //Add ,true for Edge Compatibility******************
	allInfo.open('GET', "JW1_MPAGE_ALLERGIES_JSON",true);
	//allInfo.send("MINE, $PAT_Personid$"); 
	allInfo.send("MINE, "+MPAGE_REC.PERSON_ID);
    //Added for Edge Compatibility ***Start********************
    });
    console.log("starting to wait for promise");        
    var waitForPromise = await algPromise;   
    console.log(waitForPromise); 
    //Added for Edge Compatibility ***End********************
	// return;
}

//Add async for Edge Compatibility******************
async function docTable(){
    //Added for Edge Compatibility ***Start********************
    let docPromise = new Promise(function(resolve) {
    //Added for Edge Compatibility ***End********************

	// Initialize the request object
	var docInfo = new XMLCclRequest();

	// Get the response
	docInfo.onreadystatechange = function () {
		if (docInfo.readyState == 4 && docInfo.status == 200) {
			// var xmlDoc = loadXMLString(docInfo.responseText);
            var xmlDoc = docInfo.responseText;
			if (xmlDoc != undefined && xmlDoc != null && xmlDoc > " ") {
				var jsonDoc = eval('(' + xmlDoc + ')');
			}

			if (jsonDoc){
				var tableBody = ["<table>"];
                // Start building the patient information table
                var tableBody = [
                	"<table>", 
                	"<thead>",
                	"<tr>",
                		"<td class='diagnosticsCol1Hdr'>&nbsp;</td>",
                		"<td class='diagnosticsCol3Hdr'>Date/Time</td>",
                	"</tr>",
                	"</thead>",
                	"<tbody>"]; 
                    
				for (var i=0,aLen=jsonDoc.DOCUMENTS.DOCUMENT.length;i<aLen;i++) {
					var docObj = jsonDoc.DOCUMENTS.DOCUMENT[i]; 
                    var paramStr = "^MINE^,"+docObj.EVENT_ID;

					tableBody.push(    
					"<tr>",
						"<td class='diagnosticsCol1'>", docObj.TITLE,"</td>",
						"<td class='diagnosticsCol2'><a href=\"javascript:CCLLINK( 'mp_rtf_view', '"+paramStr+"', 0)\";>",docObj.DATE,"</a></td>",
					"</tr>");
				}  // end for

				// Close the table
				tableBody.push("</table>");

                // Insert the table into the patient information section
                document.getElementById('documentTable').innerHTML  = tableBody.join("");
                //Added for Edge Compatibility ***Start********************
                resolve("Finished getting Document data");            
                //Added for Edge Compatibility ***End********************
			} //if (jsonAllergy)


		};   //if
	} //function

	//  Call the ccl progam and send the parameter string
    //Add ,true for Edge Compatibility******************
	docInfo.open('GET', "JW1_MPAGE_DOCUMENTS",true);
	//docInfo.send("MINE, $PAT_Personid$, $VIS_Encntrid$");
	docInfo.send("MINE, "+MPAGE_REC.PERSON_ID+", "+MPAGE_REC.ENCNTR_ID);
    //Added for Edge Compatibility ***Start********************
    });
    console.log("starting to wait for promise");        
    var waitForPromise = await docPromise;   
    console.log(waitForPromise); 
    //Added for Edge Compatibility ***End********************
	// return;
}


function tabLink (desc,firstTab,appl) {
	var nMode = 0;
	var vcAppName = appl;
	var vcDescription = desc;
	var vcParams = "/PERSONID=$PAT_Personid$ /ENCNTRID=$VIS_Encntrid$ /FIRSTTAB="+firstTab;
	return ["<a title='Click to go to ",firstTab," Tab' href='javascript:APPLINK(",nMode,",\"",vcAppName,"\",\"",vcParams,"\");'>",vcDescription,"</a>"].join("");
}

function addAllergy() {
	var paramString =  "$PAT_Personid$|$VIS_Encntrid$|0|0|||0||0|0";
	MPAGES_EVENT("Allergy", paramString);
	allergyInfoTable();
} //end addAllergy 
