<%@ page contentType="text/html" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> 

<jsp:useBean id="dispIter" class="LiveFencing.DisplaySeriesIterator" scope="session" />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<link href="css/tableau_style.css" rel="stylesheet" type="text/css" media="screen" />
<link href="css/tableau.css" rel="stylesheet" type="text/css" media="screen" />
<link href="css/fencer_list.css" rel="stylesheet" type="text/css" media="screen" />
<script type="text/javascript">
	onerror=handleErr
	function handleErr(msg,url,l) {
		alert(msg);
		//Handle the error here
		return true;
	}

	function onPageLoaded() {
		startSwapTimers();
	}
        var swaps = new Array();
    <c:set var="partcounter" value="0" scope="page" />
    <c:forEach items="${dispIter.currentView.tableauParts}" var="thisPart">
        swaps[${partcounter}] = "swap-${partcounter}";
        <c:set var="partcounter" value="${partcounter + 1}" scope="page" />
    </c:forEach>
	var swapindex = 0;
	function onSwapTimer() {
            if (swapindex == swaps.length - 1) {
                window.location.reload();
            } else {
                var t = setTimeout("onSwapTimer()",15000);
                document.getElementById(swaps[swapindex]).style.visibility = "hidden";
                swapindex += 1;
                document.getElementById(swaps[swapindex]).style.visibility = "visible";
            }
		
	}
	function startSwapTimers() {
		var t = setTimeout("onSwapTimer()",15000);
	}

</script>

</head>
<body onload="onPageLoaded()">
<title>${dispIter.currentView.competition.name}</title>
<c:set var="partcounter" value="0" scope="page" />
<c:forEach items="${dispIter.currentView.tableauParts}" var="thisPart">
    <c:if test="${0 != partcounter}">
        <c:set var="hidden" value=" hidden" />
    </c:if>
    <div class="tableau${hidden}" id="swap-${partcounter}">
        <h2 class="tableau_title">${dispIter.currentView.competition.shortName} Last ${thisPart.round}<c:if test="${fn:length(dispIter.currentView.tableauParts) > 1}"> part ${partcounter + 1}</c:if></h2>
        <div class="r1col">
            <c:set var="boutnum" value="1" scope="page" />
            <c:forEach items="${thisPart.firstRound}" var="bout">
		<div class="r1bout-${boutnum} bout">
			<div class="de-element fencerA winner">
				<div class="fencer">${bout.fencerA_Name}</div>
				<div class="score">${bout.scoreA}</div>
			</div>
			<div class="pistecontainer">
				<div class="de-element fencerA">
					Piste: ${bout.piste}  Time:xxxx
				</div>
			</div>
			<div class="de-element fencerB loser">
				<div class="fencer">${bout.fencerB_Name}</div>
				<div class="score">${bout.scoreB}</div>
			</div>
		</div>
                
                <c:set var="boutnum" value="${boutnum + 1}" scope="page" />
            </c:forEach>
        </div>  
        <div class="r2col">
            <c:set var="boutnum" value="1" scope="page" />
            <c:forEach items="${thisPart.secondRound}" var="bout">
		<div class="r2bout-${boutnum} bout">
			<div class="de-element fencerA winner">
				<div class="fencer">${bout.fencerA_Name}</div>
				<div class="score">${bout.scoreA}</div>
			</div>
			<div class="pistecontainer">
				<div class="de-element fencerA">
					Piste: ${bout.piste}  Time:xxxx
				</div>
			</div>
			<div class="de-element fencerB loser">
				<div class="fencer">${bout.fencerB_Name}</div>
				<div class="score">${bout.scoreB}</div>
			</div>
		</div>
                
                <c:set var="boutnum" value="${boutnum + 1}" scope="page" />
            </c:forEach>
        </div>  
    </div>
    <c:set var="partcounter" value="${partcounter + 1}" scope="page" />
</c:forEach>
</body>
