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
                            sans: ['Roboto', 'ui-sans-serif', 'system-ui']
                        },
                        colors: {
                            dusty: '#B36D6D',
                            dustyHover: '#965656',
                            blush: '#F2D1D1',
                            cloud: '#FDF8F8',
                            whitePure: '#FFFFFF',
                            petal: '#EFE1E1',
                            espresso: '#3D3434',
                            successBg: '#A5D6A7',
                            successTextDark: '#1B5E20',
                            warningBg: '#FFCC80',
                            warningText: '#E65100',
                            dangerBg: '#EF9A9A',
                            dangerText: '#B71C1C'
                        }
                    }
                }
            }
        </script>

        <title>Login - Skylight Studio</title>
    </head>

    <body class="bg-cloud font-sans text-espresso min-h-screen flex items-center justify-center p-6">

        <div class="w-full max-w-4xl bg-whitePure rounded-xl shadow-lg shadow-blush/30 flex overflow-hidden border border-blush">

            <!-- LEFT SIDE (BRANDING) -->
            <div class="hidden md:flex flex-col items-center justify-center 
                 bg-dusty text-whitePure w-1/2 p-8">

                <div class="w-56 h-56 rounded-full bg-whitePure flex items-center justify-center mb-6 shadow-lg">
                    <img src="../util/skylightstudio_logo.jpg" alt="Skylight Studio Logo" 
                         class="w-40 h-40 object-contain rounded-full" />
                </div>

                <h1 class="text-2xl font-bold text-center">Skylight Studio Class Management System</h1>
                <p class="mt-2 text-center text-sm opacity-90">
                    Efficient studio management for creative professionals
                </p>
            </div>

            <!-- RIGHT SIDE (FORM) -->
            <div class="w-full md:w-1/2 p-8">

                <h1 class="text-2xl font-bold mb-2 text-left pb-2 border-b border-petal">
                    Login
                </h1>

                <!-- ERROR DISPLAY -->
                <div class="mb-4">
                    <%
                        String error = request.getParameter("error");
                        if (error != null) {
                            String errorMsg = "";
                            String alertClass = "dangerBg";
                            String alertBorder = "dangerText";
                            String alertText = "dangerText";

                            if ("invalid_credentials".equals(error)) {
                                errorMsg = "Invalid email or password";
                            } else if ("pending_approval".equals(error)) {
                                errorMsg = "Your registration is pending approval";
                                alertClass = "warningBg";
                                alertBorder = "warningText";
                                alertText = "warningText";
                            } else if ("registration_rejected".equals(error)) {
                                errorMsg = "Your registration has been rejected";
                            } else if ("not_approved".equals(error)) {
                                errorMsg = "Account not approved for login";
                            } else if ("account_inactive".equals(error)) {
                                errorMsg = "Account is inactive";
                            } else if ("database_error".equals(error)) {
                                errorMsg = "Database error occurred";
                            } else if ("invalid_input".equals(error)) {
                                errorMsg = "Please fill in all fields";
                            } else if ("access_denied".equals(error)) {
                                errorMsg = "Access denied";
                            } else if ("session_expired".equals(error)) {
                                errorMsg = "Session expired, please login again";
                            } else if ("email_not_found".equals(error)) {
                                errorMsg = "Email not found in our system";
                            } else if ("too_many_requests".equals(error)) {
                                errorMsg = "Too many reset requests. Please wait 3 hours.";
                            } else if ("reset_failed".equals(error)) {
                                errorMsg = "Failed to process reset request";
                            } else if ("invalid_token".equals(error)) {
                                errorMsg = "Invalid or expired reset link";
                            }

                            if (!errorMsg.isEmpty()) {
                    %>
                    <div class="p-3 rounded-lg border-l-4 border-<%= alertBorder%> bg-<%= alertClass%>">
                        <p class="text-<%= alertText%> font-medium">
                            <%= errorMsg%>
                        </p>
                    </div>
                    <%
                            }
                        }

                        String msg = request.getParameter("msg");
                        if ("logged_out".equals(msg)) {
                    %>
                    <div class="p-3 rounded-lg border-l-4 border-successTextDark bg-successBg">
                        <p class="text-successTextDark font-medium">
                            Successfully logged out
                        </p>
                    </div>
                    <% }%>
                </div>

                <!-- SUCCESS MESSAGES -->
                <%
                    String message = request.getParameter("message");
                    if (message != null && !message.isEmpty()) {
                        String displayMsg = "";

                        if ("reset_email_sent".equals(message)) {
                            displayMsg = "Password reset email sent. Please check your inbox.";
                        } else if ("password_reset_success".equals(message)) {
                            displayMsg = "Password reset successful! You can now login with your new password.";
                        } else {
                            displayMsg = message.replace("_", " ");
                        }
                %>
                <div class="mb-4 p-3 rounded-lg border-l-4 border-successTextDark bg-successBg">
                    <p class="text-successTextDark font-medium">
                        <%= displayMsg%>
                    </p>
                </div>
                <%
                    }
                %>

                <!-- FORM - SEMUA INPUT DALAM SATU FORM -->
                <form id="loginForm" action="../authenticate" method="POST" class="space-y-4">

                    <!-- ROLES RADIO BUTTONS - SEKARANG DALAM FORM -->
                    <fieldset class="mb-2">
                        <legend class="block mb-2 font-medium text-espresso">Login As</legend>
                        <div class="flex gap-4">
                            <label class="inline-flex items-center gap-2 cursor-pointer">
                                <input type="radio" name="role" value="admin" checked 
                                       class="text-dusty focus:ring-dusty" />
                                <span class="text-espresso">Admin</span>
                            </label>
                            <label class="inline-flex items-center gap-2 cursor-pointer">
                                <input type="radio" name="role" value="instructor" 
                                       class="text-dusty focus:ring-dusty" />
                                <span class="text-espresso">Instructor</span>
                            </label>
                        </div>
                    </fieldset>

                    <div>
                        <label for="login_email" class="block text-sm font-medium mb-1 text-espresso">
                            Email
                        </label>
                        <input
                            id="login_email"
                            name="login_email"
                            type="email"
                            required
                            class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                            placeholder="you@example.com"
                            value="<%= request.getParameter("login_email") != null ? request.getParameter("login_email") : ""%>"
                            />
                    </div>

                    <div>
                        <label for="login_password" class="block text-sm font-medium mb-1 text-espresso">
                            Password
                        </label>
                        <input
                            id="login_password"
                            name="login_password"
                            type="password"
                            required
                            class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                            placeholder="Enter your password"
                            />

                        <!-- FORGOT PASSWORD LINK -->
                        <div class="mt-1 text-right">
                            <a href="#" onclick="openPopup(); return false;"
                               class="text-dusty hover:text-dustyHover hover:underline underline-offset-2 text-sm font-medium transition-colors">
                                Forgot Password?
                            </a>
                        </div>
                    </div>

                    <!-- LOGIN BUTTON -->
                    <button type="submit"
                            class="w-full bg-dusty hover:bg-dustyHover text-whitePure p-3 rounded-lg font-medium transition-colors mt-4">
                        Login
                    </button>

                    <div class="flex items-center justify-center mt-4 text-sm pt-4 border-t border-petal">
                        <p class="text-espresso/70">
                            Don't have an account?
                            <a href="register_account.jsp" class="text-dusty hover:text-dustyHover hover:underline underline-offset-2 font-semibold ml-1 transition-colors">
                                Register Now
                            </a>
                        </p>
                    </div>

                </form>
            </div>
        </div>

        <!-- POPUP RESET PASSWORD -->
        <div id="popup"
             class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div class="bg-whitePure p-6 rounded-xl shadow-lg w-full max-w-sm border border-blush">

                <!-- Header -->
                <h2 class="text-xl font-semibold mb-2 text-center text-espresso">
                    Reset Password
                </h2>

                <p class="text-sm text-espresso/70 mb-4 text-center">
                    Enter your email to receive a password reset link.
                </p>

                <!-- Divider line -->
                <hr class="border-petal mb-4">

                <!-- Radio buttons: Login As -->
                <fieldset class="mb-4">
                    <legend class="block mb-2 font-medium text-espresso">Account Type</legend>
                    <div class="flex gap-4">
                        <label class="inline-flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="reset_role" value="admin" checked class="text-dusty focus:ring-dusty cursor-pointer"/>
                            <span class="text-espresso">Admin</span>
                        </label>
                        <label class="inline-flex items-center gap-2 cursor-pointer">
                            <input type="radio" name="reset_role" value="instructor" class="text-dusty focus:ring-dusty cursor-pointer"/>
                            <span class="text-espresso">Instructor</span>
                        </label>
                    </div>
                </fieldset>

                <!-- Email input -->
                <input id="reset_email" type="email"
                       placeholder="Enter your email"
                       class="w-full p-3 border border-blush rounded-lg mb-4 focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition" />

                <!-- Buttons -->
                <button onclick="submitReset()"
                        class="w-full bg-dusty hover:bg-dustyHover text-whitePure p-3 rounded-lg font-medium mb-2 transition-colors">
                    Submit
                </button>

                <button onclick="closePopup()"
                        class="w-full bg-petal hover:bg-blush text-espresso p-3 rounded-lg font-medium transition-colors">
                    Cancel
                </button>
            </div>
        </div>

        <script>
            // Auto-focus email field if there's error
            window.onload = function () {
                const error = '<%= request.getParameter("error")%>';
                if (error && error !== 'null') {
                    document.getElementById("login_email").focus();
                }
            };

            // Function to open forgot password popup
            function openPopup() {
                document.getElementById("popup").classList.remove("hidden");
            }

            // Function to close popup
            function closePopup() {
                document.getElementById("popup").classList.add("hidden");
                // Reset form
                document.getElementById("reset_email").value = "";
            }

            // Function to submit reset password request
            function submitReset() {
                const email = document.getElementById("reset_email").value;
                const role = document.querySelector('#popup input[name="reset_role"]:checked').value;

                if (!email) {
                    alert("Please enter your email");
                    return;
                }

                // Create hidden form to submit to ResetPasswordServlet
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '../resetPassword';

                // Email parameter
                const emailInput = document.createElement('input');
                emailInput.type = 'hidden';
                emailInput.name = 'email';
                emailInput.value = email;
                form.appendChild(emailInput);

                // Role parameter
                const roleInput = document.createElement('input');
                roleInput.type = 'hidden';
                roleInput.name = 'role';
                roleInput.value = role;
                form.appendChild(roleInput);

                // Add form to page and submit
                document.body.appendChild(form);
                form.submit();

                // Show loading in popup
                const submitBtn = document.querySelector('#popup button[onclick="submitReset()"]');
                if (submitBtn) {
                    submitBtn.innerHTML = 'Sending...';
                    submitBtn.disabled = true;
                }
            }
        </script>

    </body>
</html>