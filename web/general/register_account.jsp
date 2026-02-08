<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />

        <!-- Font Roboto -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">

        <!-- Tailwind CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Tailwind Custom Palette -->
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {
                            sans: ['Roboto', 'ui-sans-serif', 'system-ui'],
                            condensed: ['Roboto Condensed', 'ui-sans-serif'],
                            mono: ['Roboto Mono', 'monospace']
                        },
                        colors: {
                            dusty: '#B36D6D',
                            dustyHover: '#965656',
                            blush: '#F2D1D1',
                            blushHover: '#E8BEBE',
                            cloud: '#FDF8F8',
                            whitePure: '#FFFFFF',
                            petal: '#EFE1E1',
                            espresso: '#3D3434',
                            successText: '#1E3A1E',
                            warningText: '#8A6D3B',
                            dangerText: '#A94442',
                            successTextDark: '#2E7D32',
                            teal: '#6D9B9B',
                            tealSoft: '#A3C1D6',
                            tealHover: '#557878',
                            successBg: '#A5D6A7',
                            warningBg: '#FFCC80',
                            dangerBg: '#EF9A9A',
                            infoBg: '#A3C1D6',
                            chipRose: '#FCE4EC',
                            chipSand: '#D9C5B2',
                            chipTeal: '#6D9B9B'
                        }
                    }
                }
            }
        </script>

        <title>Register Account - Skylight Studio</title>
    </head>

    <body class="bg-cloud font-sans text-espresso min-h-screen flex items-center justify-center p-6">
        <main class="w-full max-w-5xl bg-whitePure rounded-xl shadow-lg shadow-blush/30 p-8 border border-blush">
            <!-- Header -->
            <div class="mb-8 pb-4 border-b border-petal">
                <h1 class="text-2xl font-semibold text-espresso">Create Account</h1>
                <p class="text-sm text-espresso/70 mt-2">
                    Choose a role and fill in your details
                </p>
            </div>

            <!-- Display Error Messages -->
            <%
                String errorMessage = (String) request.getAttribute("errorMessage");
                if (errorMessage != null) {
            %>
            <div class="mb-6 p-4 bg-dangerBg text-espresso rounded-lg border border-blush">
                <p class="font-medium">Registration Error:</p>
                <p><%= errorMessage%></p>
            </div>
            <% } %>

            <!-- Display Success Messages -->
            <%
                String successMessage = (String) request.getAttribute("successMessage");
                if (successMessage != null) {
            %>
            <div class="mb-6 p-4 bg-successBg text-successText rounded-lg border border-blush">
                <p class="font-medium">Success!</p>
                <p><%= successMessage%></p>
            </div>
            <% }%>

            <form id="registerForm" action="../register" method="POST" 
                  class="grid grid-cols-1 md:grid-cols-2 gap-8"
                  enctype="multipart/form-data">

                <!-- LEFT COLUMN -->
                <div class="flex flex-col gap-6">
                    <!-- Role Selection -->
                    <div>
                        <h2 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">Account Type</h2>

                        <fieldset>
                            <legend class="block text-sm font-medium mb-2 text-espresso">Register As <span class="text-dusty">*</span></legend>
                            <div class="flex gap-6">
                                <label class="inline-flex items-center gap-2 cursor-pointer p-3 border border-blush rounded-lg hover:bg-cloud/50 transition-colors flex-1 justify-center" 
                                       id="adminLabel">
                                    <input type="radio" name="reg_role" value="admin" id="reg_admin" 
                                           onchange="toggleForms()" 
                                           class="h-5 w-5 text-dusty focus:ring-dusty cursor-pointer" />
                                    <span class="font-medium text-espresso">Admin</span>
                                </label>
                                <label class="inline-flex items-center gap-2 cursor-pointer p-3 border border-blush rounded-lg hover:bg-cloud/50 transition-colors flex-1 justify-center"
                                       id="instructorLabel">
                                    <input type="radio" name="reg_role" value="instructor" id="reg_instructor" 
                                           onchange="toggleForms()" 
                                           class="h-5 w-5 text-dusty focus:ring-dusty cursor-pointer" checked />
                                    <span class="font-medium text-espresso">Instructor</span>
                                </label>
                            </div>
                        </fieldset>
                    </div>

                    <!-- Account Information Section -->
                    <div>
                        <h2 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">Account Information</h2>

                        <div class="space-y-4">
                            <div>
                                <label for="username" class="block text-sm font-medium mb-1 text-espresso">
                                    Username <span class="text-dusty">*</span>
                                </label>
                                <input id="username" name="username" type="text" required
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                                       placeholder="Choose a username"
                                       onblur="checkUsername()" />
                                <p id="usernameFeedback" class="text-xs mt-1"></p>
                            </div>

                            <div class="grid grid-cols-2 gap-4">
                                <div>
                                    <label for="password" class="block text-sm font-medium mb-1 text-espresso">
                                        Password <span class="text-dusty">*</span>
                                    </label>
                                    <input id="password" name="password" type="password" required minlength="6"
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                                           placeholder="Min. 6 characters"
                                           onkeyup="validatePassword()" />
                                </div>
                                <div>
                                    <label for="confirm_password" class="block text-sm font-medium mb-1 text-espresso">
                                        Confirm Password <span class="text-dusty">*</span>
                                    </label>
                                    <input id="confirm_password" name="confirm_password" type="password" required
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                                           placeholder="Re-type password"
                                           onkeyup="validatePassword()" />
                                </div>
                            </div>
                            <p id="passwordFeedback" class="text-xs text-espresso/70"></p>
                        </div>
                    </div>

                    <!-- Personal Information Section -->
                    <div>
                        <h2 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">Personal Information</h2>

                        <div class="space-y-4">
                            <div>
                                <label for="name" class="block text-sm font-medium mb-1 text-espresso">
                                    Full Name <span class="text-dusty">*</span>
                                </label>
                                <input id="name" name="name" type="text" required
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                                       placeholder="Enter your full name" />
                            </div>

                            <div>
                                <label for="email" class="block text-sm font-medium mb-1 text-espresso">
                                    Email <span class="text-dusty">*</span>
                                </label>
                                <input id="email" name="email" type="email" required
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                                       placeholder="you@example.com"
                                       onblur="checkEmail()" />
                                <p id="emailFeedback" class="text-xs mt-1"></p>
                            </div>

                            <div>
                                <label for="phone" class="block text-sm font-medium mb-1 text-espresso">
                                    Phone Number
                                </label>
                                <input id="phone" name="phone" type="tel"
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                                       placeholder="+60 12-345 6789" />
                            </div>

                            <div>
                                <label for="nric" class="block text-sm font-medium mb-1 text-espresso">
                                    NRIC <span class="text-dusty">*</span>
                                </label>
                                <input id="nric" name="nric" type="text" required
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                                       placeholder="000000000000"
                                       pattern="\d{12}"
                                       title="Enter 12-digit NRIC without dashes" />
                                <p class="text-xs text-espresso/70 mt-1">Enter 12-digit NRIC without dashes</p>
                            </div>

                            <div>
                                <label for="bod" class="block text-sm font-medium mb-1 text-espresso">
                                    Date of Birth <span class="text-dusty">*</span>
                                </label>
                                <input id="bod" name="bod" type="date" required
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- RIGHT COLUMN -->
                <div class="flex flex-col gap-6">
                    <!-- Professional Information Section (For Instructor Only) -->
                    <div id="instructor_fields" class="flex flex-col gap-6">
                        <div>
                            <h2 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">Professional Information</h2>

                            <div class="space-y-4">
                                <div>
                                    <label for="yearOfExperience" class="block text-sm font-medium mb-1 text-espresso">
                                        Years of Experience <span class="text-dusty">*</span>
                                    </label>
                                    <input id="yearOfExperience" name="yearOfExperience" type="number" min="0" required
                                           class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                                           placeholder="Enter years of experience" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Certification Section (For Both Roles) -->
                    <div>
                        <h2 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal" id="certification_title">
                            Certification / Supporting Document
                        </h2>

                        <div class="space-y-4">
                            <div>
                                <label for="certification" class="block text-sm font-medium mb-1 text-espresso" id="certification_label">
                                    Upload Document <span class="text-dusty">*</span>
                                </label>
                                <input id="certification" name="certification" type="file" required
                                       accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-teal file:text-whitePure hover:file:bg-tealHover" />
                                <p class="text-xs text-espresso/70 mt-1" id="certification_help">
                                    For Instructor: Teaching certification. For Admin: Identification or authorization document.<br>
                                    Accepted formats: PDF, JPG, PNG, DOC, DOCX (Max: 5MB)
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Profile Image Section -->
                    <div>
                        <h2 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">Profile Image</h2>

                        <div class="space-y-4">
                            <div>
                                <label for="profileImage" class="block text-sm font-medium mb-1 text-espresso">
                                    Profile Photo
                                </label>
                                <input id="profileImage" name="profileImage" type="file"
                                       accept=".jpg,.jpeg,.png"
                                       class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-teal file:text-whitePure hover:file:bg-tealHover" />
                                <p class="text-xs text-espresso/70 mt-1">Accepted formats: JPG, PNG (Max: 2MB)</p>
                            </div>

                            <div class="w-32 h-32 border-2 border-dashed border-blush rounded-lg flex items-center justify-center overflow-hidden bg-cloud/50">
                                <img id="profilePreview" src="" alt="Profile Preview" class="hidden w-full h-full object-cover" />
                                <span id="placeholderText" class="text-espresso/40 text-sm text-center p-2">Preview will appear here</span>
                            </div>
                        </div>
                    </div>

                    <!-- Address Section -->
                    <div>
                        <h2 class="text-lg font-medium text-dusty mb-4 pb-2 border-b border-petal">Address</h2>

                        <div>
                            <label for="address" class="block text-sm font-medium mb-1 text-espresso">
                                Full Address <span class="text-dusty">*</span>
                            </label>
                            <textarea id="address" name="address" required rows="4"
                                      class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition resize-none"
                                      placeholder="Enter your complete address"></textarea>
                        </div>
                    </div>
                </div>

                <!-- Submit Button Area -->
                <div class="md:col-span-2 mt-4 flex flex-col gap-4">
                    <div class="flex items-center gap-2 text-sm text-espresso/70">
                        <input id="terms" name="terms" type="checkbox" required
                               class="h-4 w-4 text-dusty focus:ring-dusty border-blush rounded" />
                        <label for="terms" class="cursor-pointer">
                            I agree to the <a href="privacy_policy.jsp" class="text-teal hover:text-tealHover font-medium">Privacy Policy</a> and 
                            <a href="#" class="text-teal hover:text-tealHover font-medium">Terms of Service</a>
                        </label>
                    </div>

                    <button type="submit"
                            class="w-full bg-dusty hover:bg-dustyHover text-whitePure p-3 rounded-lg font-medium transition-colors">
                        Register Account
                    </button>

                    <p class="text-center text-sm text-espresso/70 pt-2 border-t border-petal">
                        Already have an account?
                        <a href="login.jsp" class="text-teal hover:text-tealHover hover:underline underline-offset-2 font-semibold ml-1 transition-colors">Login here</a>
                    </p>
                </div>
            </form>
        </main>

        <script>
            // Toggle forms based on role selection
            function toggleForms() {
                const role = document.querySelector('input[name="reg_role"]:checked').value;
                const instructorFields = document.getElementById('instructor_fields');
                const yearOfExperience = document.getElementById('yearOfExperience');
                const certificationTitle = document.getElementById('certification_title');
                const certificationLabel = document.getElementById('certification_label');
                const certificationHelp = document.getElementById('certification_help');
                const adminLabel = document.getElementById('adminLabel');
                const instructorLabel = document.getElementById('instructorLabel');

                if (role === 'admin') {
                    // Hide year of experience for admin
                    instructorFields.classList.add('hidden');
                    yearOfExperience.removeAttribute('required');

                    // Update certification labels for admin
                    certificationTitle.textContent = 'Supporting Document';
                    certificationLabel.innerHTML = 'Identification / Authorization Document <span class="text-dusty">*</span>';
                    certificationHelp.innerHTML = 'For Admin: Please upload identification document or authorization letter.<br>Accepted formats: PDF, JPG, PNG, DOC, DOCX (Max: 5MB)';

                    // Update label styling
                    adminLabel.classList.add('border-dusty', 'bg-blush/30');
                    instructorLabel.classList.remove('border-dusty', 'bg-blush/30');
                } else {
                    // Show year of experience for instructor
                    instructorFields.classList.remove('hidden');
                    yearOfExperience.setAttribute('required', 'required');

                    // Update certification labels for instructor
                    certificationTitle.textContent = 'Certification Document';
                    certificationLabel.innerHTML = 'Teaching Certification <span class="text-dusty">*</span>';
                    certificationHelp.innerHTML = 'For Instructor: Please upload your teaching certification.<br>Accepted formats: PDF, JPG, PNG, DOC, DOCX (Max: 5MB)';

                    // Update label styling
                    instructorLabel.classList.add('border-dusty', 'bg-blush/30');
                    adminLabel.classList.remove('border-dusty', 'bg-blush/30');
                }
            }

            // Initialize on page load
            document.addEventListener('DOMContentLoaded', function () {
                toggleForms();

                // Add styling to the checked radio's label
                const checkedRadio = document.querySelector('input[name="reg_role"]:checked');
                if (checkedRadio.value === 'admin') {
                    document.getElementById('adminLabel').classList.add('border-dusty', 'bg-blush/30');
                } else {
                    document.getElementById('instructorLabel').classList.add('border-dusty', 'bg-blush/30');
                }
            });

            // Preview profile image
            document.getElementById('profileImage').addEventListener('change', function (e) {
                const file = e.target.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function (event) {
                        document.getElementById('profilePreview').src = event.target.result;
                        document.getElementById('profilePreview').classList.remove('hidden');
                        document.getElementById('placeholderText').classList.add('hidden');
                    }
                    reader.readAsDataURL(file);
                }
            });

            // Username validation
            function checkUsername() {
                const username = document.getElementById('username').value;
                const feedback = document.getElementById('usernameFeedback');

                if (username.length < 3) {
                    feedback.textContent = 'Username must be at least 3 characters';
                    feedback.className = 'text-xs mt-1 text-warningText';
                    return false;
                }

                // Simulate checking if username exists
                if (username.includes('admin') || username.includes('root')) {
                    feedback.textContent = 'Username is not available';
                    feedback.className = 'text-xs mt-1 text-dangerText';
                    return false;
                }

                feedback.textContent = 'Username is available';
                feedback.className = 'text-xs mt-1 text-successTextDark';
                return true;
            }

            // Email validation
            function checkEmail() {
                const email = document.getElementById('email').value;
                const feedback = document.getElementById('emailFeedback');
                const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

                if (!emailPattern.test(email)) {
                    feedback.textContent = 'Please enter a valid email address';
                    feedback.className = 'text-xs mt-1 text-warningText';
                    return false;
                }

                feedback.textContent = '';
                return true;
            }

            // Password validation
            function validatePassword() {
                const password = document.getElementById('password').value;
                const confirmPassword = document.getElementById('confirm_password').value;
                const feedback = document.getElementById('passwordFeedback');

                if (password.length < 6) {
                    feedback.textContent = 'Password must be at least 6 characters';
                    feedback.className = 'text-xs text-warningText';
                    return false;
                }

                if (password !== confirmPassword) {
                    feedback.textContent = 'Passwords do not match';
                    feedback.className = 'text-xs text-dangerText';
                    return false;
                }

                feedback.textContent = 'Passwords match ✓';
                feedback.className = 'text-xs text-successTextDark';
                return true;
            }

            // Form validation before submission
            function validateForm() {
                const role = document.querySelector('input[name="reg_role"]:checked').value;

                // Validate all fields
                if (!checkUsername() || !checkEmail() || !validatePassword()) {
                    alert('Please correct the errors in the form');
                    return false;
                }

                // Check terms
                if (!document.getElementById('terms').checked) {
                    alert('You must agree to the terms and conditions');
                    return false;
                }

                // Validate required fields based on role
                if (role === 'instructor') {
                    const yearOfExperience = document.getElementById('yearOfExperience').value;
                    if (!yearOfExperience || yearOfExperience < 0) {
                        alert('Please enter valid years of experience for Instructor');
                        return false;
                    }
                }

                // Validate certification file
                const certification = document.getElementById('certification').files[0];
                if (!certification) {
                    alert('Document upload is required for registration');
                    return false;
                }

                if (certification.size > 5 * 1024 * 1024) {
                    alert('Document file must be less than 5MB');
                    return false;
                }

                // Validate file extensions for certification
                const certFilename = certification.name.toLowerCase();
                if (!certFilename.match(/\.(pdf|jpg|jpeg|png|doc|docx)$/)) {
                    alert('Certification file must be PDF, JPG, PNG, DOC, or DOCX format');
                    return false;
                }

                // Validate file sizes for profile image
                const profileImage = document.getElementById('profileImage').files[0];
                if (profileImage && profileImage.size > 2 * 1024 * 1024) {
                    alert('Profile image must be less than 2MB');
                    return false;
                }

                // Validate file extensions for profile image
                if (profileImage) {
                    const profileFilename = profileImage.name.toLowerCase();
                    if (!profileFilename.match(/\.(jpg|jpeg|png)$/)) {
                        alert('Profile image must be JPG or PNG format');
                        return false;
                    }
                }

                // Validate NRIC format
                const nric = document.getElementById('nric').value;
                if (!nric.match(/^\d{12}$/)) {
                    alert('NRIC must be exactly 12 digits without dashes');
                    return false;
                }

                // Validate date of birth
                const bod = document.getElementById('bod').value;
                if (!bod) {
                    alert('Date of Birth is required');
                    return false;
                }

                // Calculate age
                const birthDate = new Date(bod);
                const today = new Date();
                let age = today.getFullYear() - birthDate.getFullYear();
                const monthDiff = today.getMonth() - birthDate.getMonth();
                if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
                    age--;
                }

                if (age < 18) {
                    alert('You must be at least 18 years old to register');
                    return false;
                }

                return true;
            }

            // Add form validation on submit
            document.getElementById('registerForm').addEventListener('submit', function (e) {
                if (!validateForm()) {
                    e.preventDefault();
                }
            });
        </script>
    </body>
</html>