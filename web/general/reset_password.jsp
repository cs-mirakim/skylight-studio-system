<%@ page import="com.skylightstudio.classmanagement.dao.PasswordResetDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />

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

        <title>Reset Password - Skylight Studio</title>
    </head>

    <%
        String token = request.getParameter("token");
        String error = (String) request.getAttribute("error");
        if (error == null) {
            error = request.getParameter("error");
        }

        // Validate token on page load
        if (token != null) {
            PasswordResetDAO resetDAO = new PasswordResetDAO();
            boolean validToken = false;

            try {
                validToken = resetDAO.validateToken(token);
            } catch (Exception e) {
                e.printStackTrace();
            }

            // Redirect if token invalid
            if (!validToken) {
                response.sendRedirect("login.jsp?error=invalid_token");
                return;
            }
        } else {
            // No token provided
            response.sendRedirect("login.jsp?error=invalid_token");
            return;
        }
    %>

    <body class="bg-cloud font-sans text-espresso flex items-center justify-center min-h-screen p-4">
        <div class="bg-whitePure p-6 md:p-8 rounded-xl shadow-lg shadow-blush/30 w-full max-w-md border border-blush">
            <!-- Header -->
            <h1 class="text-2xl font-bold mb-6 text-center pb-2 border-b border-petal">
                Reset Password
            </h1>

            <!-- Error Message -->
            <% if ("password_mismatch".equals(error)) { %>
            <div class="mb-4 p-3 rounded-lg border-l-4 border-dangerText bg-dangerBg">
                <p class="text-dangerText font-medium">
                    Passwords do not match. Please try again.
                </p>
            </div>
            <% } else if ("weak_password".equals(error)) { %>
            <div class="mb-4 p-3 rounded-lg border-l-4 border-warningText bg-warningBg">
                <p class="text-warningText font-medium">
                    Password must be at least 6 characters long.
                </p>
            </div>
            <% }%>

            <form id="resetForm" action="../resetPassword" method="GET" class="flex flex-col gap-4">
                <!-- Hidden token field -->
                <input type="hidden" name="token" value="<%= token%>">

                <!-- New Password -->
                <div>
                    <label for="new_password" class="block text-sm font-medium mb-1 text-espresso">
                        New Password
                    </label>
                    <input
                        id="new_password"
                        name="new_password"
                        type="password"
                        class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                        placeholder="Enter new password (min 6 characters)"
                        required
                        />
                </div>

                <!-- Confirm Password -->
                <div>
                    <label for="confirm_password" class="block text-sm font-medium mb-1 text-espresso">
                        Confirm Password
                    </label>
                    <input
                        id="confirm_password"
                        name="confirm_password"
                        type="password"
                        class="w-full p-3 border border-blush rounded-lg focus:outline-none focus:ring-2 focus:ring-dusty focus:border-transparent transition"
                        placeholder="Confirm new password"
                        required
                        />
                </div>

                <!-- Submit Button -->
                <button
                    type="submit"
                    class="w-full bg-dusty hover:bg-dustyHover text-whitePure p-3 rounded-lg font-medium transition-colors mt-2"
                    >
                    Reset Password
                </button>

                <div class="text-center mt-4 pt-4 border-t border-petal">
                    <a href="login.jsp" class="text-dusty hover:text-dustyHover hover:underline text-sm">
                        Back to Login
                    </a>
                </div>
            </form>
        </div>

        <script>
            // Form validation
            document.getElementById('resetForm').addEventListener('submit', function (e) {
                const newPwd = document.getElementById('new_password').value;
                const confirmPwd = document.getElementById('confirm_password').value;

                if (newPwd.length < 6) {
                    e.preventDefault();
                    alert('Password must be at least 6 characters long.');
                    return;
                }

                if (newPwd !== confirmPwd) {
                    e.preventDefault();
                    alert('Passwords do not match. Please try again.');
                    return;
                }
            });
        </script>
    </body>
</html>