<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.Map"%>
<%@ page import="java.util.List"%>
<%@ page import="teammates.common.util.Const"%>
<%@ page import="teammates.common.datatransfer.FeedbackParticipantType"%>
<%@ page import="teammates.common.datatransfer.FeedbackResponseAttributes"%>
<%@ page import="teammates.common.datatransfer.FeedbackResponseCommentAttributes"%>
<%@ page import="teammates.common.datatransfer.FeedbackSessionResponseStatus" %>
<%@ page import="teammates.ui.controller.InstructorFeedbackResultsPageData"%>
<%@ page import="teammates.common.datatransfer.FeedbackAbstractQuestionDetails"%>
<%@ page import="teammates.common.datatransfer.FeedbackQuestionAttributes"%>
<%
    InstructorFeedbackResultsPageData data = (InstructorFeedbackResultsPageData) request.getAttribute("data");
%>
<!DOCTYPE html>
<html>
<head>
<link rel="shortcut icon" href="/favicon.png">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>TEAMMATES - Feedback Session Results</title>
<!-- Bootstrap core CSS -->
<link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">
<!-- Bootstrap theme -->
<link href="/bootstrap/css/bootstrap-theme.min.css" rel="stylesheet">
<link rel="stylesheet" href="/stylesheets/teammatesCommon.css" type="text/css" media="screen">
<script type="text/javascript" src="/js/googleAnalytics.js"></script>
<script type="text/javascript" src="/js/jquery-minified.js"></script>
<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript" src="/js/instructor.js"></script>
<script type="text/javascript" src="/js/instructorFeedbackResults.js"></script>
<script type="text/javascript" src="/js/additionalQuestionInfo.js"></script>
<script type="text/javascript" src="/js/feedbackResponseComments.js"></script>
<jsp:include page="../enableJS.jsp"></jsp:include>
<!-- Bootstrap core JavaScript ================================================== -->
<script src="/bootstrap/js/bootstrap.min.js"></script>
<!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
<![endif]-->
</head>

<body>
    <jsp:include page="<%=Const.ViewURIs.INSTRUCTOR_HEADER%>" />

    <div id="frameBody">
        <div id="frameBodyWrapper" class="container">
            <div id="topOfPage"></div>
            <div id="headerOperation">
                <h1>Feedback Results - Instructor</h1>
            </div>
            <jsp:include page="<%=Const.ViewURIs.INSTRUCTOR_FEEDBACK_RESULTS_TOP%>" />
            <br>
            <%
                boolean groupByTeamEnabled = data.groupByTeam==null ? false : true;
                String currentTeam = null;
                boolean newTeam = false;
            %>
        <%
            Map<String, Map<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>>> allResponses = data.bundle.getResponsesSortedByRecipientQuestionGiver(groupByTeamEnabled);
            Map<String, FeedbackQuestionAttributes> questions = data.bundle.questions;
            int recipientIndex = 0;
            for (Map.Entry<String, Map<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>>> responsesForRecipient : allResponses.entrySet()) {
                recipientIndex++;
                
                Map<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>> recipientData = responsesForRecipient.getValue();
                Object[] recipientDataArray =  recipientData.keySet().toArray();
                FeedbackResponseAttributes firstResponse = recipientData.get(recipientDataArray[0]).get(0);
                String targetEmail = firstResponse.recipientEmail;

                FeedbackParticipantType firstQuestionRecipientType = questions.get(firstResponse.feedbackQuestionId).recipientType;
                String mailtoStyleAttr = (firstQuestionRecipientType == FeedbackParticipantType.NONE || 
                                firstQuestionRecipientType == FeedbackParticipantType.TEAMS)?"style=\"display:none;\"":"";
        %>

        <%
            if(currentTeam != null && !currentTeam.equals(data.bundle.getTeamNameForEmail(targetEmail))) {
                currentTeam = data.bundle.getTeamNameForEmail(targetEmail);
                newTeam = true;
        %>
                </div>
            </div>
        <%
            }
            if(groupByTeamEnabled == true && (currentTeam==null || newTeam==true)) {
                currentTeam = data.bundle.getTeamNameForEmail(targetEmail);
                newTeam = false;
        %>
                <div class="panel panel-warning">
                    <div class="panel-heading">
                        <strong><%=currentTeam%></strong>
                    </div>
                    <div class="panel-body background-color-warning">
        <%
            }
        %>


                <div class="panel panel-primary">
                <div class="panel-heading">
                    To: <strong><%=responsesForRecipient.getKey()%></strong>
                        <a class="link-in-dark-bg" href="mailTo:<%= targetEmail%> " <%=mailtoStyleAttr%>>[<%=targetEmail%>]</a>
                </div>
                <div class="panel-body">
                <%
                    int questionIndex = 0;
                    for (Map.Entry<FeedbackQuestionAttributes, List<FeedbackResponseAttributes>> responsesForRecipientForQuestion : responsesForRecipient.getValue().entrySet()) {
                        questionIndex++;
                        FeedbackQuestionAttributes question = responsesForRecipientForQuestion.getKey();
                        FeedbackAbstractQuestionDetails questionDetails = question.getQuestionDetails();
                        List<FeedbackResponseAttributes> responseEntries = responsesForRecipientForQuestion.getValue();
                %>
                        <div class="panel panel-info">
                            <div class="panel-heading">Question <%=question.questionNumber%>: <%
                                    out.print(InstructorFeedbackResultsPageData.sanitizeForHtml(questionDetails.questionText));
                                    out.print(questionDetails.getQuestionAdditionalInfoHtml(question.questionNumber, "recipient-"+recipientIndex+"-question-"+questionIndex));%>
                            </div>
                            <div class="panel-body">
                                <table class="table table-striped table-bordered dataTable margin-0">
                                    <thead class="fill-primary">
                                        <tr>
                                            <th id="button_sortTo" onclick="toggleSort(this,1,null,2)" colspan="2">
                                                From
                                            </th>
                                            <th id="button_sortFeedback" onclick="toggleSort(this,3,null,2)" rowspan="2" style="vertical-align:middle;">
                                                Feedback
                                            </th>
                                        </tr>
                                        <tr>
                                            <th id="button_sortFromName" onclick="toggleSort(this,1,null,2)" style="width: 15%;">
                                                Name
                                            </th>
                                            <th id="button_sortFromTeam" onclick="toggleSort(this,2,null,2)" style="width: 15%;">
                                                Team
                                            </th>
                                        </tr>
                                    <thead>
                                    <tbody>
                                        <%
                                            for(FeedbackResponseAttributes responseEntry: responseEntries) {
                                        %>
                                        <tr>
                                        <%
                                            String giverName = data.bundle.getGiverNameForResponse(question, responseEntry);
                                            String giverTeamName = data.bundle.getTeamNameForEmail(responseEntry.giverEmail);
                                        %>
                                            <td class="middlealign"><%=giverName%></td>
                                            <td class="middlealign"><%=giverTeamName%></td>
                                            <td class="multiline"><%=responseEntry.getResponseDetails().getAnswerHtml()%></td>
                                        </tr>        
                                        <%
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                <%
                    }
                %>
                </div>
            </div>
        <%
            }
        %>

        <%
            //close the last team panel.
            if(groupByTeamEnabled==true) {
        %>
                    </div>
                </div>
        <%
            }
        %>

        <%
            // Only output the list of students who haven't responded when there are responses.
            FeedbackSessionResponseStatus responseStatus = data.bundle.responseStatus;
            if (!responseStatus.hasResponse.isEmpty()) {
        %>
                <div class="panel panel-info">
                    <div class="panel-heading">Additional Information</div>
                    
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Students Who Did Not Respond to Any Question</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            for (String studentName : responseStatus.getStudentsWhoDidNotRespondToAnyQuestion()) {
                        %>
                                <tr>
                                    <td><%=studentName%></td>
                                </tr>
                        <%
                            }
                        %>
                        </tbody>
                    </table>
                </div>
                <br> <br>
        <%
            }
        %>
        </div>
    </div>

    <jsp:include page="<%=Const.ViewURIs.FOOTER%>" />
</body>
</html>