--Cleaning data in SQL

SELECT*
FROM NashvilleHousing

--Standardize date format

--SELECT SaleDate, CONVERT (Date,SaleDate)
--FROM NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT (Date,SaleDate)

--Added a column SaleDateConverted, specified the data type

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;
--Converted the new column from date time to Date format
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date,SaleDate)


--Populate Property address data 
SELECT *
FROM NashvilleHousing
where PropertyAddress is null

--self join the table
--ISNULL checks if a.property address is null then populates the property address in b in a.propertyaddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--when using joins you use the alias with the update statement
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual column (Address, City, State)
--SUBSTRING specifies the position
--To remove the comma from appearing in the address column, use -1

Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From NashvilleHousing

---add 2 newcolumns
ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress  = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add City nvarchar(255);

UPDATE NashvilleHousing
SET City = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

--GET THE STATE FROM OWNER ADDRESS USING PARSENAME
--PARSENAME IS FUNCTIONAL WHEN THE DELIMITER IS PERIODS. OUR DATA  HAS COMMAS SO WE REPLACE THEM INTO PERIODS
--PARSENAME separates things backwards
Select
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add State nvarchar(255);

UPDATE NashvilleHousing
SET State = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)

--CHANGE Y AND N TO Yes and No in SoldAsVacant using CASE Statement

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
from NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


--REMOVE DUPLICATES
WITH CTE_NashHousing as
(
Select *, ROW_NUMBER() OVER (PARTITION BY ParcelID,PropertyAddress ORDER BY UniqueID) as ROWNUMBER
FROM NashvilleHousing
)

DELETE FROM CTE_NashHousing WHERE ROWNUMBER > 1

--Delete Unused Column

 ALTER TABLE NashvilleHousing
 DROP COLUMN  OwnerAddress, PropertyAddress

 ALTER TABLE NashvilleHousing
 DROP COLUMN  SaleDate
