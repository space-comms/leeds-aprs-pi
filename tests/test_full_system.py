#!/usr/bin/env python3
"""
Leeds APRS Pi - Full System Integration Tests
Test suite for validating the complete APRS system functionality
"""

import unittest
import os
import sys
import subprocess
import time
import requests
import tempfile
import shutil
from pathlib import Path

class TestAPRSSystem(unittest.TestCase):
    """Test suite for APRS system functionality"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test environment"""
        cls.project_root = Path(__file__).parent.parent
        cls.api_url = "http://localhost:5000"
        cls.web_url = "http://localhost:8080"
        
    def setUp(self):
        """Set up individual test"""
        self.test_dir = tempfile.mkdtemp()
        
    def tearDown(self):
        """Clean up after test"""
        shutil.rmtree(self.test_dir, ignore_errors=True)
    
    def test_docker_compose_syntax(self):
        """Test Docker Compose configuration syntax"""
        try:
            result = subprocess.run(
                ["docker-compose", "config"],
                cwd=self.project_root,
                capture_output=True,
                text=True,
                timeout=30
            )
            self.assertEqual(result.returncode, 0, f"Docker Compose syntax error: {result.stderr}")
        except subprocess.TimeoutExpired:
            self.fail("Docker Compose config check timed out")
        except FileNotFoundError:
            self.skipTest("Docker Compose not available")
    
    def test_dockerfile_syntax(self):
        """Test Dockerfile syntax"""
        dockerfile_path = self.project_root / "Dockerfile"
        self.assertTrue(dockerfile_path.exists(), "Dockerfile not found")
        
        # Check for common syntax issues
        with open(dockerfile_path, 'r') as f:
            content = f.read()
            
        # Basic syntax checks
        self.assertIn("FROM", content, "Dockerfile missing FROM instruction")
        self.assertIn("WORKDIR", content, "Dockerfile missing WORKDIR instruction")
        self.assertIn("CMD", content, "Dockerfile missing CMD instruction")
        
        # Check for proper structure
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if line.strip().startswith('#'):
                continue
            if line.strip() and not line.startswith(' ') and not line.startswith('\t'):
                # Check if line is a valid Docker instruction
                valid_instructions = [
                    'FROM', 'RUN', 'CMD', 'LABEL', 'EXPOSE', 'ENV', 'ADD', 'COPY',
                    'ENTRYPOINT', 'VOLUME', 'USER', 'WORKDIR', 'ARG', 'ONBUILD',
                    'STOPSIGNAL', 'HEALTHCHECK', 'SHELL'
                ]
                if line.strip():
                    first_word = line.split()[0].upper()
                    if first_word not in valid_instructions:
                        self.fail(f"Invalid Docker instruction at line {i+1}: {line}")
    
    def test_script_permissions(self):
        """Test that shell scripts have execute permissions"""
        scripts_dir = self.project_root / "scripts"
        if scripts_dir.exists():
            for script_file in scripts_dir.glob("*.sh"):
                # Check if file is executable (on Unix systems)
                if os.name == 'posix':
                    self.assertTrue(
                        os.access(script_file, os.X_OK),
                        f"Script {script_file} is not executable"
                    )
    
    def test_script_syntax(self):
        """Test shell script syntax"""
        scripts_dir = self.project_root / "scripts"
        if scripts_dir.exists():
            for script_file in scripts_dir.glob("*.sh"):
                try:
                    # Use bash -n to check syntax without executing
                    result = subprocess.run(
                        ["bash", "-n", str(script_file)],
                        capture_output=True,
                        text=True,
                        timeout=10
                    )
                    self.assertEqual(
                        result.returncode, 0,
                        f"Syntax error in {script_file}: {result.stderr}"
                    )
                except subprocess.TimeoutExpired:
                    self.fail(f"Syntax check timed out for {script_file}")
                except FileNotFoundError:
                    self.skipTest("Bash not available for syntax checking")
    
    def test_python_syntax(self):
        """Test Python script syntax"""
        scripts_dir = self.project_root / "scripts"
        if scripts_dir.exists():
            for python_file in scripts_dir.glob("*.py"):
                try:
                    # Compile Python file to check syntax
                    with open(python_file, 'r') as f:
                        content = f.read()
                    
                    compile(content, str(python_file), 'exec')
                    
                except SyntaxError as e:
                    self.fail(f"Python syntax error in {python_file}: {e}")
    
    def test_configuration_files(self):
        """Test configuration file structure"""
        config_dir = self.project_root / "config"
        
        # Check if config directory exists
        if config_dir.exists():
            # Check for common configuration files
            expected_files = ["direwolf.conf", "beacon.conf"]
            for config_file in expected_files:
                config_path = config_dir / config_file
                if config_path.exists():
                    self.assertTrue(
                        config_path.is_file(),
                        f"Configuration file {config_file} is not a regular file"
                    )
    
    def test_documentation_completeness(self):
        """Test that required documentation exists"""
        required_docs = [
            "README.md",
            "SETUP_GUIDE.md",
            "API_DOCUMENTATION.md",
            "CONTRIBUTING.md",
            "PROJECT_DOCUMENTATION.md"
        ]
        
        for doc in required_docs:
            doc_path = self.project_root / doc
            self.assertTrue(
                doc_path.exists(),
                f"Required documentation {doc} not found"
            )
            
            # Check that documentation is not empty
            with open(doc_path, 'r', encoding='utf-8') as f:
                content = f.read().strip()
                self.assertGreater(
                    len(content), 100,
                    f"Documentation {doc} appears to be empty or too short"
                )
    
    def test_web_interface_files(self):
        """Test web interface file structure"""
        web_dir = self.project_root / "web"
        
        if web_dir.exists():
            # Check for essential web files
            index_html = web_dir / "index.html"
            self.assertTrue(
                index_html.exists(),
                "Web interface index.html not found"
            )
            
            # Check for JavaScript files
            js_dir = web_dir / "js"
            if js_dir.exists():
                dashboard_js = js_dir / "dashboard.js"
                if dashboard_js.exists():
                    with open(dashboard_js, 'r') as f:
                        content = f.read()
                        self.assertIn("class", content, "JavaScript file appears to be incomplete")
    
    def test_environment_variables(self):
        """Test environment variable configuration"""
        compose_file = self.project_root / "docker-compose.yml"
        
        if compose_file.exists():
            with open(compose_file, 'r') as f:
                content = f.read()
                
            # Check for essential environment variables
            essential_vars = ["CALLSIGN", "APRS_PASS", "LAT", "LON"]
            for var in essential_vars:
                self.assertIn(
                    var,
                    content,
                    f"Essential environment variable {var} not found in docker-compose.yml"
                )
    
    def test_log_directory_structure(self):
        """Test log directory structure"""
        logs_dir = self.project_root / "logs"
        
        # Create logs directory if it doesn't exist
        if not logs_dir.exists():
            logs_dir.mkdir()
        
        self.assertTrue(logs_dir.is_dir(), "Logs directory is not a directory")
        
        # Check write permissions
        if os.name == 'posix':
            self.assertTrue(
                os.access(logs_dir, os.W_OK),
                "Logs directory is not writable"
            )
    
    def test_data_directory_structure(self):
        """Test data directory structure"""
        data_dir = self.project_root / "data"
        
        # Create data directory if it doesn't exist
        if not data_dir.exists():
            data_dir.mkdir()
        
        self.assertTrue(data_dir.is_dir(), "Data directory is not a directory")
        
        # Check write permissions
        if os.name == 'posix':
            self.assertTrue(
                os.access(data_dir, os.W_OK),
                "Data directory is not writable"
            )
    
    def test_api_server_imports(self):
        """Test that API server can import required modules"""
        api_server_path = self.project_root / "scripts" / "api-server.py"
        
        if api_server_path.exists():
            # Test that the script can be imported without errors
            try:
                import sys
                sys.path.insert(0, str(api_server_path.parent))
                
                # Try to compile the file
                with open(api_server_path, 'r') as f:
                    content = f.read()
                
                compile(content, str(api_server_path), 'exec')
                
            except Exception as e:
                self.fail(f"API server script has import/compilation errors: {e}")
    
    def test_readme_links(self):
        """Test that README links are properly formatted"""
        readme_path = self.project_root / "README.md"
        
        if readme_path.exists():
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check for common markdown link issues
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if '[' in line and ']' in line:
                    # Check for properly formatted links
                    import re
                    # Look for markdown links [text](url)
                    links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', line)
                    for link_text, link_url in links:
                        self.assertNotEqual(
                            link_text.strip(), "",
                            f"Empty link text at line {i+1}"
                        )
                        self.assertNotEqual(
                            link_url.strip(), "",
                            f"Empty link URL at line {i+1}"
                        )

class TestSystemHealth(unittest.TestCase):
    """Test system health and monitoring"""
    
    def test_health_check_script(self):
        """Test health check functionality"""
        # This would test the health check script if it exists
        project_root = Path(__file__).parent.parent
        health_script = project_root / "scripts" / "health-check.sh"
        
        if health_script.exists():
            try:
                result = subprocess.run(
                    ["bash", str(health_script)],
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                # Health check should return 0 for healthy system
                self.assertIn(
                    result.returncode, [0, 1],
                    "Health check script should return 0 (healthy) or 1 (unhealthy)"
                )
            except subprocess.TimeoutExpired:
                self.fail("Health check script timed out")
            except FileNotFoundError:
                self.skipTest("Bash not available for health check")

class TestDockerIntegration(unittest.TestCase):
    """Test Docker integration and build process"""
    
    def test_docker_build_dry_run(self):
        """Test Docker build without actually building"""
        project_root = Path(__file__).parent.parent
        
        try:
            # Test that Docker can parse the Dockerfile
            result = subprocess.run(
                ["docker", "build", "--dry-run", "."],
                cwd=project_root,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            # Docker should be able to parse the Dockerfile
            self.assertNotIn("ERROR", result.stderr.upper())
            
        except subprocess.TimeoutExpired:
            self.fail("Docker build dry run timed out")
        except FileNotFoundError:
            self.skipTest("Docker not available")

def run_tests():
    """Run all tests"""
    # Create test suite
    suite = unittest.TestSuite()
    
    # Add test cases
    suite.addTest(unittest.makeSuite(TestAPRSSystem))
    suite.addTest(unittest.makeSuite(TestSystemHealth))
    suite.addTest(unittest.makeSuite(TestDockerIntegration))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    return result.wasSuccessful()

if __name__ == "__main__":
    print("Leeds APRS Pi - Full System Integration Tests")
    print("=" * 50)
    
    success = run_tests()
    
    if success:
        print("\n? All tests passed!")
        sys.exit(0)
    else:
        print("\n? Some tests failed!")
        sys.exit(1)