# Leeds APRS Pi
**Contributing Guidelines**

---

## Welcome Contributors

Thank you for your interest in contributing to the Leeds APRS Pi project! This project is primarily maintained for Leeds Space Comms members but welcomes contributions from the wider amateur radio community.

---

## Code of Conduct

### Our Standards

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of:
- Experience level with amateur radio or software development
- Background or identity
- Geographic location
- Equipment or technical setup

### Expected Behavior

- **Be respectful**: Treat all contributors with respect and courtesy
- **Be helpful**: Assist newcomers and share knowledge freely
- **Be collaborative**: Work together to improve the project
- **Be constructive**: Provide helpful feedback and suggestions

### Unacceptable Behavior

- Harassment or discrimination of any kind
- Offensive or inappropriate language
- Personal attacks or trolling
- Spam or off-topic discussions

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:
- Basic knowledge of amateur radio and APRS
- Familiarity with Docker and containerization
- Understanding of Git and GitHub workflows
- Access to Raspberry Pi hardware (preferred but not required)

### Development Environment

#### Required Software
```bash
# Install development tools
sudo apt-get install git docker.io docker-compose
sudo usermod -aG docker $USER

# Clone the repository
git clone https://github.com/leedsspace/leeds-aprs-pi.git
cd leeds-aprs-pi

# Build and test
docker-compose build
docker-compose up -d
```

#### Recommended Tools
- **VS Code**: With Docker and Git extensions
- **Git GUI**: For visual Git management
- **Documentation tools**: For editing markdown files

---

## Contribution Types

### Bug Reports

#### Before Reporting
- Check existing issues for duplicates
- Test with the latest version
- Gather system information and logs

#### Bug Report Template
```markdown
**Bug Description**
A clear description of the bug

**Steps to Reproduce**
1. Step one
2. Step two
3. Step three

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happened

**Environment**
- Raspberry Pi model:
- OS version:
- Docker version:
- Hardware setup:

**Logs**
```
Include relevant log excerpts
```

### Feature Requests

#### Before Requesting
- Check if feature already exists
- Consider if it fits project scope
- Think about implementation complexity

#### Feature Request Template
```markdown
**Feature Description**
Clear description of the requested feature

**Use Case**
Why this feature would be useful

**Implementation Ideas**
Suggestions for how it could be implemented

**Alternatives**
Alternative solutions you've considered
```

### Code Contributions

#### Types of Contributions Welcome
- **Bug fixes**: Fixing identified issues
- **Feature enhancements**: Adding new functionality
- **Documentation**: Improving guides and references
- **Testing**: Adding tests and validation
- **Optimization**: Performance improvements

#### Not Suitable for This Project
- Major architectural changes (discuss first)
- Features unrelated to APRS/amateur radio
- Hardware-specific optimizations for non-Pi platforms
- Changes that break existing functionality

---

## Development Guidelines

### Coding Standards

#### Shell Scripts
```bash
#!/bin/bash
#
# Changelog - script_name.sh
#
# [Initial]
# - Brief description of the script purpose
# - Key functionality points
# - Dependencies and requirements
#
# [Purpose]
# - Main purpose of the script
# - Target audience or use case
# - Integration with other components
#

# Use strict error handling
set -e

# Clear variable definitions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/app/logs/script.log"

# Descriptive function names
function setup_hardware() {
    # Implementation
}

# Proper error handling
if ! command -v docker &> /dev/null; then
    echo "Docker not found" >&2
    exit 1
fi
```

#### Docker Configuration
```dockerfile
#
# Changelog - Dockerfile
#
# [Initial]
# - Purpose and scope of the container
# - Base image selection rationale
# - Key dependencies and tools
#
# [Purpose]
# - Container functionality description
# - Target deployment environment
# - Integration requirements
#

# Use specific base image versions
FROM arm64v8/debian:bullseye-slim

# Group related RUN commands
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    package3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clear documentation
LABEL description="Brief description of container purpose"
```

#### Documentation Standards
```markdown
# Section Title
**Brief Description**

## Overview
Clear explanation of the section content

### Subsection
Detailed information with examples

#### Code Examples
```bash
# Well-commented code examples
command --option=value
```

#### Best Practices
- Use consistent markdown formatting
- Include practical examples
- Explain complex concepts clearly
- Link to relevant resources
```

### Testing Requirements

#### Manual Testing
- Test on actual Raspberry Pi hardware
- Verify with different hardware configurations
- Check network connectivity scenarios
- Validate configuration options

#### Automated Testing
```bash
# Test script structure
#!/bin/bash
# Test description and purpose

# Setup test environment
setup_test_environment() {
    # Test setup code
}

# Test functions
test_basic_functionality() {
    # Test implementation
}

# Cleanup
cleanup_test_environment() {
    # Cleanup code
}
```

---

## Submission Process

### Pull Request Process

#### Before Submitting
1. **Fork the repository** to your GitHub account
2. **Create a feature branch** from `main`
3. **Make your changes** following coding standards
4. **Test thoroughly** on Pi hardware if possible
5. **Update documentation** as needed
6. **Create pull request** with clear description

#### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Other: ___________

## Testing
- [ ] Tested on Raspberry Pi hardware
- [ ] Verified with Docker Compose
- [ ] Checked different configurations
- [ ] Updated documentation

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Commented complex code sections
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

### Review Process

#### Review Criteria
- **Functionality**: Does it work as intended?
- **Code Quality**: Follows project standards?
- **Documentation**: Properly documented?
- **Testing**: Adequately tested?
- **Compatibility**: Works with existing setup?

#### Review Timeline
- **Initial Review**: Within 1 week
- **Feedback**: Constructive and specific
- **Follow-up**: Response within 1 week
- **Approval**: After all requirements met

---

## Specialized Contributions

### Hardware Support

#### Adding New Hardware
```bash
# Hardware detection template
detect_new_hardware() {
    # Detection logic
    if [[ hardware_condition ]]; then
        log "New hardware detected"
        configure_new_hardware
    fi
}

# Configuration function
configure_new_hardware() {
    # Configuration steps
    # Error handling
    # Validation
}
```

#### Hardware Documentation
- **Compatibility**: Tested hardware list
- **Wiring**: Clear wiring diagrams
- **Configuration**: Setup instructions
- **Troubleshooting**: Common issues and solutions

### Educational Content

#### Tutorial Contributions
- **Beginner-friendly**: Assume basic knowledge only
- **Step-by-step**: Clear sequential instructions
- **Visual aids**: Diagrams and screenshots
- **Practical examples**: Real-world scenarios

#### Academic Integration
- **Course alignment**: Match university curriculum
- **Learning objectives**: Clear educational goals
- **Assessment ideas**: Potential project assessments
- **Resources**: Additional learning materials

---

## Recognition and Credits

### Contributor Recognition

#### Types of Recognition
- **README credits**: Listed in contributors section
- **Changelog entries**: Author attribution
- **Release notes**: Major contribution highlighting
- **Hall of fame**: Significant contributors page

#### Contribution Tracking
- **GitHub insights**: Automatic contribution tracking
- **Manual recognition**: For non-code contributions
- **Annual review**: Yearly contributor highlights

### Leeds Space Comms Members

#### Special Recognition
- **Club newsletter**: Feature contributions
- **Meeting presentations**: Showcase work
- **Academic credit**: Course project integration
- **Reference letters**: For significant contributions

---

## Community Guidelines

### Communication Channels

#### Primary Channels
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Pull Requests**: Code review and collaboration

#### Leeds Space Comms Members
- **Club meetings**: In-person discussion
- **Internal forum**: Club-specific discussions


## Legal and Licensing

### License Information

#### MIT License
- **Permission**: Free to use, modify, distribute
- **Conditions**: Include license and copyright notice
- **Limitations**: No warranty or liability

#### Contribution License
By contributing, you agree that your contributions will be licensed under the MIT License.

### Amateur Radio Considerations

#### Regulatory Compliance
- **Licensing**: Ensure amateur radio license compliance
- **RF exposure**: Follow applicable safety guidelines
- **Third-party**: Respect third-party traffic rules

#### Attribution Requirements
- **Callsign**: Include your callsign in contributions
- **Club affiliation**: Note Leeds Space Comms involvement
- **Educational use**: Highlight educational purpose

---

## Future Roadmap

### Planned Features

#### Short-term (Next 3 months)
- Enhanced hardware detection
- Improved documentation
- Better error handling
- Performance optimizations

#### Medium-term (3-6 months)
- Web interface enhancements
- Additional hardware support
- Educational content expansion
- Testing framework

#### Long-term (6+ months)
- Advanced APRS features
- Integration with other systems
- Research applications
- Community tools

### How to Influence Direction

#### Suggestion Process
1. **Discuss in issues**: Propose ideas
2. **Community feedback**: Gather input
3. **Feasibility assessment**: Technical review
4. **Implementation planning**: Development roadmap

---

## Thank You

### Acknowledgments

We appreciate all contributors who help make this project better for the amateur radio community. Your efforts help promote education, experimentation, and innovation in amateur radio.

    Primary Developer - Al-Musbahi

### Contact Information

- **Leeds Space Comms**: https://github.com/space-comms
- **GitHub Issues**: For technical questions
- **Community Forum**: For general discussions

---

*These guidelines are maintained by Leeds Space Comms for the amateur radio community.*
