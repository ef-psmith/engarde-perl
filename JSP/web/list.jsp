<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>


<jsp:useBean id="dispIter" class="LiveFencing.DisplaySeriesIterator" scope="session" />
<c:if test="${!(empty param.seriesName) && !(empty dispIter.currentView)}">
    <jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
    <jsp:setProperty name="dispIter" property="sessionName" value="${param.sessionName}" />
    ${lfo:setTournOnDispSeriesIter(dispIter,tourn,param.seriesName)}
</c:if>
<c:set var="pageRefreshTime" value="80" />
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<link href="css/tableau_style.css" rel="stylesheet" type="text/css" media="screen" />
<link href="css/vlist.css" rel="stylesheet" type="text/css" media="screen" />
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
                    
		onPauseTimer();
	}
	var top = 0;
        var pageStartTop=0;
	function onPauseTimer() {
            pageStartTop = top;
            t1=setTimeout("onScrollTimer()",pauseTime);
	}

	function onScrollTimer() {
            var topVal = top + 'px';
            document.getElementById("vert_list_id").style.top = topVal;
            top -= 5;
            if (top <= pageStartTop - scrollLimit || top + listheight < 0) {             
                if (top + listheight < 0) {
                    window.location.reload();
                } else {
                    onPauseTimer();
                }
            } else {
                t2=setTimeout("onScrollTimer()",50);
            }
	}

</script>

</head>
<body onload="onPageLoaded()">
<title id="list_title"  >${dispIter.currentView.competition.name}</title>

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
</div></body>
