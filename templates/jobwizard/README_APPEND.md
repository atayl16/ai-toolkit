

## JobWizard Setup

This application was scaffolded with `dev new jobwizard` and includes:

- **Job tracking models**: `JobPosting`, `JobSource`
- **Fetcher services**: Greenhouse, Lever integrations
- **Resume builder**: PDF generation with Prawn
- **Rules engine**: Smart job filtering and scoring

### Truth Policy

**Never fabricate experience, skills, or achievements.** All resume content must be verifiable and accurate. This tool helps organize and present real data, not create fiction.

### Configuration

Edit these files to customize:
- `config/job_wizard/profile.yml` - Your professional profile
- `config/job_wizard/experience.yml` - Work history, education
- `config/job_wizard/rules.yml` - Job filtering and scoring rules

### Usage

```bash
# Fetch jobs from a specific company
rails jobs:fetch[greenhouse,shopify]

# View job board dashboard
rails jobs:board

# Generate resume
rails resume:build

# Start server and browse
rails server
# Visit: http://localhost:3000/jobs
```

### Development Ports

- **Rails API**: `http://localhost:3000`
- **React Client** (if using rails-react): `http://localhost:5173`

### Testing

```bash
just test          # Run full test suite
just lint          # Check code quality
just sec           # Run security scans
```




