package com.skylightstudio.classmanagement.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Registration implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer registerID;
    private String userType;
    private String status;
    private Timestamp registerDate;
    private String adminMessage;

    public Registration() {
    }

    public void setRegisterID(Integer registerID) {
        this.registerID = registerID;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setRegisterDate(Timestamp registerDate) {
        this.registerDate = registerDate;
    }

    public void setAdminMessage(String adminMessage) {
        this.adminMessage = adminMessage;
    }

    public Integer getRegisterID() {
        return registerID;
    }

    public String getUserType() {
        return userType;
    }

    public String getStatus() {
        return status;
    }

    public Timestamp getRegisterDate() {
        return registerDate;
    }

    public String getAdminMessage() {
        return adminMessage;
    }
}
