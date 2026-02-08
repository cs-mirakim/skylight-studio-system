package com.skylightstudio.classmanagement.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class ClassConfirmation implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer confirmID;
    private Integer classID;
    private Integer instructorID;
    private String action;
    private Timestamp actionAt;
    private String cancellationReason;
    private Timestamp cancelledAt;

    public ClassConfirmation() {
    }

    public void setConfirmID(Integer confirmID) {
        this.confirmID = confirmID;
    }

    public void setClassID(Integer classID) {
        this.classID = classID;
    }

    public void setInstructorID(Integer instructorID) {
        this.instructorID = instructorID;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public void setActionAt(Timestamp actionAt) {
        this.actionAt = actionAt;
    }

    public void setCancellationReason(String cancellationReason) {
        this.cancellationReason = cancellationReason;
    }

    public void setCancelledAt(Timestamp cancelledAt) {
        this.cancelledAt = cancelledAt;
    }

    public Integer getConfirmID() {
        return confirmID;
    }

    public Integer getClassID() {
        return classID;
    }

    public Integer getInstructorID() {
        return instructorID;
    }

    public String getAction() {
        return action;
    }

    public Timestamp getActionAt() {
        return actionAt;
    }

    public String getCancellationReason() {
        return cancellationReason;
    }

    public Timestamp getCancelledAt() {
        return cancelledAt;
    }
}
