package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.FeedbackDAO;
import com.skylightstudio.classmanagement.model.Feedback;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.Calendar;

@WebServlet(name = "FeedbackServlet", urlPatterns = {"/FeedbackServlet"})
public class FeedbackServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");

        if ("checkStatus".equals(action)) {
            checkFeedbackStatus(request, out);
        } else {
            out.print("{\"success\":false,\"message\":\"Invalid action\"}");
        }

        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // DEBUG - Print semua parameters yang servlet receive
        System.out.println("=== DEBUG RECEIVED PARAMETERS ===");
        System.out.println("instructorID: " + request.getParameter("instructorID"));
        System.out.println("classID: " + request.getParameter("classID"));
        System.out.println("teachingSkill: " + request.getParameter("teachingSkill"));
        System.out.println("communication: " + request.getParameter("communication"));
        System.out.println("supportInteraction: " + request.getParameter("supportInteraction"));
        System.out.println("punctuality: " + request.getParameter("punctuality"));
        System.out.println("overallRating: " + request.getParameter("overallRating"));
        System.out.println("comments: " + request.getParameter("comments"));
        System.out.println("=================================");

        try {
            // Get parameters from form
            int instructorId = Integer.parseInt(request.getParameter("instructorID"));
            int classId = Integer.parseInt(request.getParameter("classID"));
            int teachingSkill = Integer.parseInt(request.getParameter("teachingSkill"));
            int communication = Integer.parseInt(request.getParameter("communication"));
            int supportInteraction = Integer.parseInt(request.getParameter("supportInteraction"));
            int punctuality = Integer.parseInt(request.getParameter("punctuality"));
            int overallRating = Integer.parseInt(request.getParameter("overallRating"));
            String comments = request.getParameter("comments");

            // Validate required fields
            if (teachingSkill < 1 || teachingSkill > 5
                    || communication < 1 || communication > 5
                    || supportInteraction < 1 || supportInteraction > 5
                    || punctuality < 1 || punctuality > 5
                    || overallRating < 1 || overallRating > 5) {

                out.print("{\"success\":false,\"message\":\"All ratings must be between 1 and 5 stars.\"}");
                return;
            }

            // Create Feedback object
            Feedback feedback = new Feedback();
            feedback.setInstructorID(instructorId);
            feedback.setClassID(classId);
            feedback.setTeachingSkill(teachingSkill);
            feedback.setCommunication(communication);
            feedback.setSupportInteraction(supportInteraction);
            feedback.setPunctuality(punctuality);
            feedback.setOverallRating(overallRating);
            feedback.setComments(comments);
            feedback.setFeedbackDate(new Date(Calendar.getInstance().getTime().getTime()));

            // Save to database
            FeedbackDAO feedbackDao = new FeedbackDAO();
            boolean success = feedbackDao.submitFeedback(feedback);

            if (success) {
                out.print("{\"success\":true,\"message\":\"Feedback submitted successfully.\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"Failed to submit feedback. Please try again.\"}");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Invalid rating values. Please select all required ratings.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"An error occurred: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }

        out.flush();
    }

    private void checkFeedbackStatus(HttpServletRequest request, PrintWriter out) {
        try {
            int classId = Integer.parseInt(request.getParameter("classID"));
            int instructorId = Integer.parseInt(request.getParameter("instructorID"));

            FeedbackDAO feedbackDao = new FeedbackDAO();
            boolean alreadySubmitted = feedbackDao.feedbackExists(classId, instructorId);

            out.print("{\"success\":true,\"alreadySubmitted\":" + alreadySubmitted + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error checking feedback status\"}");
        }
    }
}
