<%-- 
    Document   : view
    Created on : 08-Apr-2008, 21:47:48
    Author     : Oliver
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>


<jsp:useBean id="dispIter" class="LiveFencing.DisplaySeriesIterator" scope="session" />
<c:if test="${!(empty param.seriesName)}">
    <jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
    <jsp:setProperty name="dispIter" property="sessionName" value="${param.sessionName}" />
    ${lfo:setTournOnDispSeriesIter(dispIter,tourn,param.seriesName)}
</c:if>
<c:choose>
    <c:when test="${empty dispIter.nextView}">
        
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        
        <meta http-equiv="refresh" content="83;url=view.jsp" />
    </head>
    <body>
        <h2>No views to display</h2>
    </body>
</html>
    </c:when>

    <c:when test="${dispIter.currentView.type ne 'none' || dispIter.currentView.tableau ne 'none'}" >
<c:set var="pageRefreshTime" value="80" />
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<link href="css/tableau_style.css" rel="stylesheet" type="text/css" media="screen" />
<link href="css/<c:if test="${dispIter.currentView.tableau ne 'none'}">tableau</c:if><c:if test="${dispIter.currentView.type ne 'none'}">vlist</c:if>.css" rel="stylesheet" type="text/css" media="screen" />
<link href="css/fencer_list.css" rel="stylesheet" type="text/css" media="screen" />
<script type="text/javascript">
	onerror=handleErr
	function handleErr(msg,url,l) {
		alert(msg);
		//Handle the error here
		return true;
	}
        var listheight = screen.height/2;
        var scrollLimit = 0;
        var pauseTime = 0;
	function onPageLoaded() {
            <c:if test="${dispIter.currentView.tableau ne 'none'}">  
		startSwapTimers();
            </c:if>
            <c:if test="${dispIter.currentView.type ne 'none'}">
		onPauseTimer();
                var listElement = document.getElementById("vert_list_id");
                listheight = listElement.offsetHeight;
                var listContainerElement = document.getElementById("list_cont_id");
                var contheight = listContainerElement.offsetHeight;
                var listElementElement = document.getElementById("list_row_0");
                var elemheight = listElementElement.offsetHeight;
                var listHeaderElement = document.getElementById("vert_list_header_id");
                var headerheight = listHeaderElement.offsetHeight;
                var titleheight = listHeaderElement.offsetTop;
                 
                scrollLimit = contheight - elemheight - headerheight - titleheight;
                pauseTime = Math.floor(${pageRefreshTime} * 1000 / (Math.floor(listheight/scrollLimit) + 2));
                //alert("List height: "+listheight+"\nContainer height: "+contheight+"\nElement height: "+elemheight+"\Header height: "+headerheight+"\Title height: "+titleheight+"\nScreen height: "+screen.height+"\nScroll Limit: "+scrollLimit+"\nPause Time: "+pauseTime);
            </c:if>  
	}
        <c:if test="${dispIter.currentView.type ne 'none'}">
	var top = 0;
        var pageStartTop=0;
	function onPauseTimer() {
            pageStartTop = top;
            t1=setTimeout("onScrollTimer()",pauseTime);
	}

        var list_finished = false;
	function onScrollTimer() {
            var topVal = top + 'px';
            document.getElementById("vert_list_id").style.top = topVal;
            top -= 5;
            if (top <= pageStartTop - scrollLimit || top + listheight < 0) {             
                if (top + listheight < 0) {
                    list_finished = true;
                    checkFinished();
                } else {
                    onPauseTimer();
                }
            } else {
                t2=setTimeout("onScrollTimer()",50);
            }
	}
        </c:if>
        <c:if test="${dispIter.currentView.tableau ne 'none'}">  
            
        var swaps = new Array();
    <c:set var="partcounter" value="0" scope="page" />
    <c:forEach items="${dispIter.currentView.tableauParts}" var="thisPart">
        swaps[${partcounter}] = "swap-${partcounter}";
        <c:set var="partcounter" value="${partcounter + 1}" scope="page" />
    </c:forEach>
        var tableau_finished = false;
	var swapindex = 0;
	function onSwapTimer() {
            if (swapindex == swaps.length - 1) {
                tableau_finished = true;
                checkFinished();
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
        </c:if>

        function checkFinished() {
            if (true <c:if test="${dispIter.currentView.tableau ne 'none'}"> && tableau_finished</c:if><c:if test="${dispIter.currentView.type ne 'none'}"> && list_finished</c:if>) {
                window.location.reload();
            }
        }

</script>

</head>
<body onload="onPageLoaded()">
<title id="list_title"  >${dispIter.currentView.competition.name}</title>
<c:if test="${dispIter.currentView.type ne 'none'}">
<div class="vert_list_container" id="list_cont_id">
    <c:choose>
        <c:when test="${'entry' eq dispIter.currentView.type}">
            <jsp:include page="WEB-INF/jspf/entry.jsp" />
        </c:when>
        <c:when test="${'seeding' eq dispIter.currentView.type}">
            <jsp:include page="WEB-INF/jspf/seeding.jsp" />
        </c:when>
        <c:when test="${'result' eq dispIter.currentView.type}">
            <jsp:include page="WEB-INF/jspf/result.jsp" />
        </c:when>
    </c:choose>
</div>
</c:if>
<c:if test="${dispIter.currentView.tableau ne 'none'}">
            <jsp:include page="WEB-INF/jspf/tableau.jsp" />
</c:if>
</body>
</html>
    </c:when>
    
    <c:otherwise>
            
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        
        <meta http-equiv="refresh" content="83;url=view.jsp" />
    </head>
    <body>
        <h2>Not sure which view to display</h2>
    </body>
</html>
    </c:otherwise>
    
</c:choose> 
