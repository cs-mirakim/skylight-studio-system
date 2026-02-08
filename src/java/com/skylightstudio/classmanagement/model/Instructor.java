package com.skylightstudio.classmanagement.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

public class Instructor implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer instructorID;
    private Integer registerID;
    private String username;
    private String password;
    private String name;
    private String email;
    private String phone;
    private String nric;
    private String profileImageFilePath;
    private Date bod;
    private String certificationFilePath;
    private Integer yearOfExperience;
    private String address;
    private String status;
    private Timestamp dateJoined;
    private Integer reviewedBy;
    private Timestamp reviewedAt;

    public Instructor() {
    }

    public void setInstructorID(Integer instructorID) {
        this.instructorID = instructorID;
    }

    public void setRegisterID(Integer registerID) {
        this.registerID = registerID;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setNric(String nric) {
        this.nric = nric;
    }

    public void setProfileImageFilePath(String profileImageFilePath) {
        this.profileImageFilePath = profileImageFilePath;
    }

    public void setBod(Date bod) {
        this.bod = bod;
    }

    public void setCertificationFilePath(String certificationFilePath) {
        this.certificationFilePath = certificationFilePath;
    }

    public void setYearOfExperience(Integer yearOfExperience) {
        this.yearOfExperience = yearOfExperience;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setDateJoined(Timestamp dateJoined) {
        this.dateJoined = dateJoined;
    }

    public void setReviewedBy(Integer reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public void setReviewedAt(Timestamp reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public Integer getInstructorID() {
        return instructorID;
    }

    public Integer getRegisterID() {
        return registerID;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getNric() {
        return nric;
    }

    public String getProfileImageFilePath() {
        return profileImageFilePath;
    }

    public Date getBod() {
        return bod;
    }

    public String getCertificationFilePath() {
        return certificationFilePath;
    }

    public Integer getYearOfExperience() {
        return yearOfExperience;
    }

    public String getAddress() {
        return address;
    }

    public String getStatus() {
        return status;
    }

    public Timestamp getDateJoined() {
        return dateJoined;
    }

    public Integer getReviewedBy() {
        return reviewedBy;
    }

    public Timestamp getReviewedAt() {
        return reviewedAt;
    }
}
