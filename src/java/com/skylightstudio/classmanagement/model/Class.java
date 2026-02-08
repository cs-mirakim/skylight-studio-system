package com.skylightstudio.classmanagement.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Time;

public class Class implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer classID;
    private String className;
    private String classType;
    private String classLevel;
    private Date classDate;
    private Time classStartTime;
    private Time classEndTime;
    private Integer noOfParticipant;
    private String location;
    private String description;
    private String classStatus;
    private String qrcodeFilePath;
    private Integer adminID;

    public Class() {
    }

    public void setClassID(Integer classID) {
        this.classID = classID;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public void setClassType(String classType) {
        this.classType = classType;
    }

    public void setClassLevel(String classLevel) {
        this.classLevel = classLevel;
    }

    public void setClassDate(Date classDate) {
        this.classDate = classDate;
    }

    public void setClassStartTime(Time classStartTime) {
        this.classStartTime = classStartTime;
    }

    public void setClassEndTime(Time classEndTime) {
        this.classEndTime = classEndTime;
    }

    public void setNoOfParticipant(Integer noOfParticipant) {
        this.noOfParticipant = noOfParticipant;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setClassStatus(String classStatus) {
        this.classStatus = classStatus;
    }

    public void setQrcodeFilePath(String qrcodeFilePath) {
        this.qrcodeFilePath = qrcodeFilePath;
    }

    public void setAdminID(Integer adminID) {
        this.adminID = adminID;
    }

    public Integer getClassID() {
        return classID;
    }

    public String getClassName() {
        return className;
    }

    public String getClassType() {
        return classType;
    }

    public String getClassLevel() {
        return classLevel;
    }

    public Date getClassDate() {
        return classDate;
    }

    public Time getClassStartTime() {
        return classStartTime;
    }

    public Time getClassEndTime() {
        return classEndTime;
    }

    public Integer getNoOfParticipant() {
        return noOfParticipant;
    }

    public String getLocation() {
        return location;
    }

    public String getDescription() {
        return description;
    }

    public String getClassStatus() {
        return classStatus;
    }

    public String getQrcodeFilePath() {
        return qrcodeFilePath;
    }

    public Integer getAdminID() {
        return adminID;
    }
}
