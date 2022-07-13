// global variables
var bookDataFromLocalStorage = [];

// Validation rules
var insertValid =$("#fieldList").kendoValidator({
    rules: {

        customInputRequired: function(input){
            // all of the input must have a value
            return $.trim(input.val()) !== "" ;
          },
    }, 
    messages: {
        customInputRequired : "Input cannot be a blank key",

    }
}).data("kendoValidator");


$(function(){
    loadBookData();
    var data = [
        {text:"資料庫",value:"database"},
        {text:"網際網路",value:"internet"},
        {text:"應用系統整合",value:"system"},
        {text:"家庭保健",value:"home"},
        {text:"語言",value:"language"}
    ]
    $("#book_category").kendoDropDownList({
        dataTextField: "text",
        dataValueField: "value",
        dataSource: data,
        index: 0,
        change: onBookCategoryChange
    });

   
    $("#bought_datepicker").kendoDatePicker({

        animation:{
            close:{
                effects:"zoom:out",   
                duration:200,        
            },
            open:{
                effects:"zoom:in",  
                duration:200,
            }
        },
        format: "yyyy-MM-dd",
        max :new Date(),
        value: new Date(),
        weekNumber:true,
    });

    // Make the first half disabled
    $("#bought_datepicker").attr("disabled","disabled");

    $("#book_grid").kendoGrid({
        dataSource: {
            data: bookDataFromLocalStorage,
            schema: {
                model: {
                    fields: {
                        BookId: {type:"int"},
                        BookName: { type: "string" },
                        BookCategory: { type: "string" },
                        BookAuthor: { type: "string" },
                        BookBoughtDate: { type: "string" },
                        BookPublisher: { type: "string" }
                    }
                }
            },
            pageSize: 20,
        },

        
        toolbar: kendo.template(
            "<div class='book-grid-toolbar'><input class='book-grid-search' id='book-grid-search' oninput='searchBookData() ' placeholder='我想要找......' type='text'></input></div>"),
        
 
        height: 550,
        sortable: true,
        pageable: {
            input: true,
            numeric: false
        },
        columns: [
            { field: "BookId", title: "書籍編號",width:"10%"},
            { field: "BookName", title: "書籍名稱", width: "50%" },
            { field: "BookCategory", title: "書籍種類", width: "10%" },
            { field: "BookAuthor", title: "作者", width: "15%" },
            { field: "BookBoughtDate", title: "購買日期", width: "15%" },
            { field: "BookPublisher", title: "出版商", width: "15%" },
            { command: { text: "刪除", click: deleteBook }, title: " ", width: "120px" }
        ]
        

        
    }).data("kendoGrid");



})




/** window insert function */
$(function() {

    var addBook =$("#addBook");
    var myWindow = $("#window-insert");
    var undo = $("#undo");

    undo.click(function() {
        myWindow.data("kendoWindow").open();
        $("#fieldList").data("kendoValidator").reset();
        undo.fadeOut();
    });

    // close the window
    function onCloseInsert() {
        undo.fadeIn();

        //Added window input field recovery
        $("#book_name").val("");
        $("#book_author").val("");
        $("#bought_datepicker").data("kendoDatePicker").value(new Date().toISOString().split('T')[0]);
        //$("#bought_datepicker").data("kendoDatePicker").value(new Date());
        $("#book_publisher").val("");
    }

    myWindow.kendoWindow({
        width: "400px",
        height: "540px",
        title: "新增",
        visible: false,
        // Specifies whether the Window will display a modal overlay over the page.
        modal:true,
        actions: [
            "Pin",
            "Minimize",
            "Maximize",
            "Close"
        ],
        close:onCloseInsert
    }).data("kendoWindow").center();


    // add book function
    addBook.click(function(){


        var bookCategory =$("#book_category").data("kendoDropDownList").text();
        var bookName = $("#book_name").val();
        var bookAuthor = $("#book_author").val();
        var bookName = $("#book_name").val();
        //TODO: 取datepicker
        var boughtDate = $("#bought_datepicker").val();
        var bookPublisher = $("#book_publisher").val()
        // Kendo validator
        
        if(insertValid.validate()){

            var detail = {
                "BookId":bookDataFromLocalStorage[bookDataFromLocalStorage.length - 1].BookId + 1,
                "BookCategory":bookCategory,
                "BookName":bookName,
                "BookAuthor":bookAuthor,
                "BookBoughtDate":boughtDate,
                "BookPublisher":bookPublisher
                }

                bookDataFromLocalStorage.push(detail)
                localStorage.setItem("bookData",JSON.stringify(bookDataFromLocalStorage));
                loadBookData();
                
                // References https://www.telerik.com/forums/how-to-add-new-record-to-grid
                var dataSource = $("#book_grid").data('kendoGrid').dataSource;
                dataSource.add(detail);
                myWindow.data("kendoWindow").close();
        }

       

    })
       
});

function loadBookData(){
    bookDataFromLocalStorage = JSON.parse(localStorage.getItem("bookData"));
    if(bookDataFromLocalStorage == null){
        bookDataFromLocalStorage = bookData;
        localStorage.setItem("bookData",JSON.stringify(bookDataFromLocalStorage));
    }
}

// 可以更加優化
/** function search*/
function searchBookData() {
    let filterOperator = "contains";
    let filterValue = $("#book-grid-search").val();

    $("#book_grid").data("kendoGrid").dataSource.filter({
        logic: "or",
        filters: [
            { field: "BookId", operator: "eq", value: filterValue },
            { field: "BookName", operator: filterOperator, value: filterValue },
            { field: "BookCategory", operator: filterOperator, value: filterValue },
            { field: "BookAuthor", operator: filterOperator, value: filterValue },
            { field: "BookBoughtDate", operator: filterOperator, value: filterValue },
            { field: "BookPublisher", operator: filterOperator, value: filterValue }
        ]
    });

};
    



//Change the picture//
function onBookCategoryChange(){
    $("#book-image").attr("src","image/"+$("#book_category").data("kendoDropDownList").value()+".jpg")
}

// delete the book from bookDataFromLocalStorage
function deleteBook(event){

    // js 冒泡事件預防
    event.preventDefault();


    var beDeleted =  $("#book_grid").data("kendoGrid").dataItem($(event.currentTarget).closest("tr"));
    var grid = $("#book_grid").data("kendoGrid");
    var index = grid.dataSource.indexOf(beDeleted);

    //splice(index,num),num = number to delete from index
    if(confirm("Are you sure you want to delete this book?")){
        bookDataFromLocalStorage.splice(index,1)
        localStorage.setItem("bookData",JSON.stringify(bookDataFromLocalStorage));

        $("#book_grid").data("kendoGrid").dataSource.read()
        $("#book_grid").data("kendoGrid").refresh()

        //刪除時會出現問題所以加上去的
        // TODO: 比對
        grid.dataSource.removeRow(beDeleted)

        // TODO: 頁數

    }
    
   
}
