import {courses} from './data.js'

for(const course of courses) {
    const {name, credits} = course
    console.log(name,credits)
}

const courselist = courses.map(course => {
    return `${course.code} - ${course.name}(${course.credits} credits)`
})
console.log(courselist)


const hightCreditCourses = courses.filter(course => course.credits >= 4)
console.log(hightCreditCourses)
console.log("Count",hightCreditCourses.length)

const totalCredits = courses.reduce((sum,course) => sum + course.credits,0)
console.log("Total Credits",totalCredits)

courses.forEach(course => {
    console.log(`${course.name} - ${course.credits}`)
})

const gridContainer = document.getElementsByClassName('course-grid')
const Input = document.getElementById('SearchInput')
const sortBtn = document.getElementById('sortBtn')

courses.forEach(course => {
    const courseCard = document.createElement('article')
    courseCard.classList.add('coursesCard')
    courseCard.innerHTML = `
    <h3>${course.name}</h3>
    <p>${course.code}</p>
    <span>${course.credits}</span>
    `

    gridContainer[0].appendChild(courseCard)
})

Input.addEventListener('input',() => {
    const inputText = Input.value.toLowerCase()

    const filteredCourses = courses.filter(course => course.name.toLowerCase().includes(inputText))

    gridContainer[0].innerHTML = "";

    filteredCourses.forEach(course => {
        const courseCard = document.createElement('article')
        courseCard.classList.add('coursesCard')
        courseCard.innerHTML = `
        <h3>${course.name}</h3>
        <p>${course.code}</p>
        <span>${course.credits}</span>
        `

        gridContainer[0].appendChild(courseCard)
    })
})

sortBtn.addEventListener('click',() => {
    const sortedCourses = courses.sort((a,b) => b.credits - a.credits)

    gridContainer[0].innerHTML = ""

    sortedCourses.forEach(course=> {
        const courseCard = document.createElement('article')
        courseCard.classList.add('coursesCard')
        courseCard.innerHTML = `
        <h3>${course.name}</h3>
        <p>${course.code}</p>
        <span>${course.credits}</span>
        `

        gridContainer[0].appendChild(courseCard)
    })

})