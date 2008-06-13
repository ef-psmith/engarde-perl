<%-- any content can be specified here e.g.: --%>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>

<h2 class="list_title" style="background-color: ${dispIter.currentView.competition.colour}">${dispIter.currentView.competition.name} entries</h2>
	<div class="list_header" id="vert_list_header_id">
		<table>
			<tr>
				<td class="fencer_name">Fencer</td>
				<td class="fencer_club">Club</td>
				<td class="init_rank">Ranking</td>
				<td class="poule_num">Poule</td>
				<td class="piste_num">Piste</td>
			</tr>
		</table>
	</div>
	<div class="list_body" >
		<table class="list_table" id="vert_list_id">
                     <c:set var="listIter" value="0" />
                     <c:forEach items="${dispIter.currentView.competition.entries}" var="entry">
                         <tr id="list_row_${listIter}" <c:if test="${0 == listIter % 2}" > style="background-color: ${dispIter.currentView.competition.colour}" </c:if> >
				<td class="fencer_name">${entry.name}</td>
				<td class="fencer_club">${entry.club}</td>
				<td class="init_rank">${entry.ranking}</td>
				<td class="poule_num">${entry.poule}</td>
				<td class="piste_num">${entry.piste}</td>
			</tr>
                         <c:set var="listIter" value="${listIter+1}" />
                     </c:forEach>
			
		</table>
	</div>
