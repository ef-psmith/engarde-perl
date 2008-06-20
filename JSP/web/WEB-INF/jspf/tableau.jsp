<%-- any content can be specified here e.g.: --%>
<%@ page pageEncoding="UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
                     <div class="de-element fencerA ${lfo:getfencerstate(bout,"A")}">
				<div class="fencer">${bout.fencerA_Name}</div>
				<div class="score">${bout.scoreA}</div>
			</div>
			<div class="pistecontainer">
				<div class="de-element fencerA">
					Piste: ${bout.piste}  Time:xxxx
				</div>
			</div>
			<div class="de-element fencerB ${lfo:getfencerstate(bout,"B")}">
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
			<div class="de-element fencerA ${lfo:getfencerstate(bout,"A")}">
				<div class="fencer">${bout.fencerA_Name}</div>
				<div class="score">${bout.scoreA}</div>
			</div>
			<div class="pistecontainer">
				<div class="de-element fencerA">
					Piste: ${bout.piste}  Time:xxxx
				</div>
			</div>
			<div class="de-element fencerB ${lfo:getfencerstate(bout,"B")}">
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
