// Transparent rules shared by eligibility previews and application submission.
function checkEligibility(student, drive, departments, now = new Date()) {
 const reasons=[];
 if(Number(student.cgpa)<Number(drive.min_cgpa)) reasons.push(`CGPA ${student.cgpa} is below the minimum ${drive.min_cgpa}.`);
 if(!departments.includes(student.department)) reasons.push(`${student.department} is not an eligible department.`);
 if(Number(student.active_backlogs)>Number(drive.max_active_backlogs)) reasons.push(`Active backlogs (${student.active_backlogs}) exceed the maximum (${drive.max_active_backlogs}).`);
 if(Number(student.graduation_year)!==Number(drive.graduation_year)) reasons.push(`Graduation year must be ${drive.graduation_year}.`);
 if(drive.status!=='published') reasons.push('This drive is not open for applications.');
 if(new Date(drive.application_deadline).getTime()<now.getTime()) reasons.push('The application deadline has passed.');
 return {eligible:reasons.length===0,reasons};
}
module.exports={checkEligibility};
