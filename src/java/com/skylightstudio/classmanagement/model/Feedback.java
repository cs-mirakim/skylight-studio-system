package com.skylightstudio.classmanagement.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

public class Feedback implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer feedbackID;
    private Integer instructorID;
    private Integer classID;
    private Integer teachingSkill;
    private Integer communication;
    private Integer supportInteraction;
    private Integer punctuality;
    private Integer overallRating;
    private String comments;
    private Date feedbackDate;
    private Timestamp submissionTime;  // New field

    public Feedback() {
    }

    // Getters and Setters
    public Integer getFeedbackID() {
        return feedbackID;
    }

    public void setFeedbackID(Integer feedbackID) {
        this.feedbackID = feedbackID;
    }

    public Integer getInstructorID() {
        return instructorID;
    }

    public void setInstructorID(Integer instructorID) {
        this.instructorID = instructorID;
    }

    public Integer getClassID() {
        return classID;
    }

    public void setClassID(Integer classID) {
        this.classID = classID;
    }

    public Integer getTeachingSkill() {
        return teachingSkill;
    }

    public void setTeachingSkill(Integer teachingSkill) {
        this.teachingSkill = teachingSkill;
    }

    public Integer getCommunication() {
        return communication;
    }

    public void setCommunication(Integer communication) {
        this.communication = communication;
    }

    public Integer getSupportInteraction() {
        return supportInteraction;
    }

    public void setSupportInteraction(Integer supportInteraction) {
        this.supportInteraction = supportInteraction;
    }

    public Integer getPunctuality() {
        return punctuality;
    }

    public void setPunctuality(Integer punctuality) {
        this.punctuality = punctuality;
    }

    public Integer getOverallRating() {
        return overallRating;
    }

    public void setOverallRating(Integer overallRating) {
        this.overallRating = overallRating;
    }

    public String getComments() {
        return comments;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    public Date getFeedbackDate() {
        return feedbackDate;
    }

    public void setFeedbackDate(Date feedbackDate) {
        this.feedbackDate = feedbackDate;
    }

    public Timestamp getSubmissionTime() {
        return submissionTime;
    }

    public void setSubmissionTime(Timestamp submissionTime) {
        this.submissionTime = submissionTime;
    }
    
    // Helper method to calculate average rating
    public Double getAverageRating() {
        if (teachingSkill == null || communication == null || supportInteraction == null || 
            punctuality == null || overallRating == null) {
            return null;
        }
        return (teachingSkill + communication + supportInteraction + punctuality + overallRating) / 5.0;
    }
    
    @Override
    public String toString() {
        return "Feedback{" +
               "feedbackID=" + feedbackID +
               ", instructorID=" + instructorID +
               ", classID=" + classID +
               ", teachingSkill=" + teachingSkill +
               ", communication=" + communication +
               ", supportInteraction=" + supportInteraction +
               ", punctuality=" + punctuality +
               ", overallRating=" + overallRating +
               ", comments='" + (comments != null ? (comments.length() > 50 ? comments.substring(0, 50) + "..." : comments) : "null") + "'" +
               ", feedbackDate=" + feedbackDate +
               ", submissionTime=" + submissionTime +
               '}';
    }
}